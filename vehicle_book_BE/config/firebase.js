import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

let db;

try {
    // If you have a service account JSON file, provide its path in .env as FIREBASE_SERVICE_ACCOUNT_PATH
    // Otherwise, you can initialize with default credentials if running in a GCP environment
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
        const fs = await import('fs');
        const path = await import('path');
        const serviceAccountPath = path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
    } else {
        // Fallback for environment variables if preferred
        admin.initializeApp({
            credential: admin.credential.cert({
                projectId: process.env.FIREBASE_PROJECT_ID,
                clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
            })
        });
    }

    db = admin.firestore();
    console.log('✅ Firebase Firestore connected!');
} catch (error) {
    console.error('❌ Firebase connection failed:', error.message);
}

export { admin, db };
