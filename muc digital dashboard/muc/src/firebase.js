import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
// In production, consider using environment variables (e.g., import.meta.env.VITE_FIREBASE_API_KEY)
const firebaseConfig = {
  apiKey: "AIzaSyAe4oeEmqgUTBRow6oGQg-lL86WGPxIM08",
  authDomain: "muc-digital-4390a.firebaseapp.com",
  databaseURL: "https://muc-digital-4390a-default-rtdb.firebaseio.com",
  projectId: "muc-digital-4390a",
  storageBucket: "muc-digital-4390a.firebasestorage.app",
  messagingSenderId: "492466770104",
  appId: "1:492466770104:web:d4a6d04761ef2fef74a44d",
  measurementId: "G-PBL12DDNWR"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;
