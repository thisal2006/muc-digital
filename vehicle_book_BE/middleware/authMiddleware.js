import { admin } from '../config/firebase.js';

export const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: No token provided or invalid format',
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    
    // Verify the token using Firebase Admin
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Attach user info to the request object
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying Firebase token:', error);
    return res.status(401).json({
      success: false,
      message: 'Unauthorized: Invalid or expired token',
    });
  }
};
