import os
import json
import requests
from datetime import timedelta
from flask import Flask, request, jsonify, session
from flask_session import Session
from flask_cors import CORS
import chromadb
from openai import OpenAI
from dotenv import load_dotenv

# -----------------------------
# 1. Load Environment Variables
# -----------------------------
load_dotenv()

app = Flask(__name__)
#------------------------

# -----------------------------
# 2. SESSION CONFIGURATION
# -----------------------------
app.config['SECRET_KEY'] = os.getenv("OPENROUTER_API_KEY")
app.config['SESSION_TYPE'] = 'filesystem'
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)
app.config['SESSION_PERMANENT'] = True

Session(app)
CORS(app, supports_credentials=True)

# -----------------------------
# 3. LLM SETUP (OpenRouter)
# -----------------------------
client = OpenAI(
    api_key=os.getenv("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# -----------------------------
# 4. HUGGING FACE CLOUD EMBEDDING
# -----------------------------
class HuggingFaceEmbeddingFunction:
    def __init__(self):
        self.api_url = "https://router.huggingface.co/hf-inference/models/BAAI/bge-small-en-v1.5"
        self.headers = {
            "Authorization": f"Bearer {os.getenv('HF_TOKEN')}"
        }

    def __call__(self, input):
        embeddings = []

        for text in input:
            response = requests.post(
                self.api_url,
                headers=self.headers,
                json={"inputs": text},
                timeout=30
            )

            if response.status_code != 200:
                raise Exception(f"HuggingFace API Error: {response.text}")

            payload = response.json()
            if isinstance(payload, list):
                embeddings.append(payload)
            elif isinstance(payload, dict) and isinstance(payload.get("embedding"), list):
                embeddings.append(payload["embedding"])
            elif isinstance(payload, dict) and isinstance(payload.get("embeddings"), list):
                if payload["embeddings"] and isinstance(payload["embeddings"][0], list):
                    embeddings.append(payload["embeddings"][0])
                else:
                    embeddings.append(payload["embeddings"])
            else:
                raise Exception(f"Unexpected HuggingFace embedding response format: {payload}")

        return embeddings

    def embed_documents(self, input):
        return self.__call__(input)

    def embed_query(self, input):
        return self.__call__(input)

    def name(self):
        return "huggingface-bge-small"

# -----------------------------
# 5. CHROMA DB SETUP
# -----------------------------
emb_fn = HuggingFaceEmbeddingFunction()

chroma_client = chromadb.PersistentClient(path="./muc_vector_db")

collection = chroma_client.get_or_create_collection(
    name="muc_faq_v1",
    embedding_function=emb_fn
)

# -----------------------------
# 6. DATA INGESTION
# -----------------------------
def ingest_faq():
    if collection.count() == 0:
        try:
            with open('question.json', 'r') as f:
                data = json.load(f)

            documents = []
            metadatas = []
            ids = []

            for category in data['categories']:
                cat_name = category['category']
                for q in category['questions']:
                    content = f"Category: {cat_name}\nQuestion: {q['question']}\nSteps: {' '.join(q['steps'])}"
                    documents.append(content)
                    metadatas.append({"category": cat_name})
                    ids.append(str(q['id']))

            collection.add(
                documents=documents,
                metadatas=metadatas,
                ids=ids
            )

            print("✅ Successfully indexed question.json into ChromaDB")

        except FileNotFoundError:
            print("❌ Error: question.json not found!")
        except Exception as e:
            print(f"❌ Error during ingestion: {e}")

ingest_faq()

# -----------------------------
# 7. CHAT ENDPOINT
# -----------------------------
@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_query = data.get("message")

    if not user_query:
        return jsonify({"error": "No message provided"}), 400

    if 'history' not in session:
        session['history'] = [
            {
                "role": "system",
                "content": "You are the MUC Digital Assistant for Maharagama Urban Council. Use the provided context to answer questions. Be polite and professional."
            }
        ]

    # Retrieve context from Chroma
    results = collection.query(
        query_texts=[user_query],
        n_results=1
    )

    context = ""
    if results['documents'] and len(results['documents'][0]) > 0:
        context = results['documents'][0][0]

    augmented_prompt = f"""
Use this official information to answer the user:

{context}

User Question: {user_query}
"""

    messages_for_llm = session['history'] + [
        {"role": "user", "content": augmented_prompt}
    ]

    try:
        response = client.chat.completions.create(
            model="openrouter/free",
            messages=messages_for_llm
        )

        bot_reply = response.choices[0].message.content

        session['history'].append({"role": "user", "content": user_query})
        session['history'].append({"role": "assistant", "content": bot_reply})

        # Keep only last 10 exchanges
        if len(session['history']) > 11:
            session['history'] = [session['history'][0]] + session['history'][-10:]

        session.modified = True

        return jsonify({"reply": bot_reply})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------------
# 8. RESET SESSION
# -----------------------------
@app.route('/reset', methods=['POST'])
def reset():
    session.clear()
    return jsonify({"message": "Chat history cleared"}), 200


# -----------------------------
# 9. RUN SERVER
# -----------------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)