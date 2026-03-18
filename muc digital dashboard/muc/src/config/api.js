import { auth } from '../firebase';

export const API_BASE_URL =
 'https://vehicle-api-608720602568.asia-south1.run.app/api';
 //'http://localhost:3000/api';

export const fetchWithAuth = async (url, options = {}) => {
  let token = null;
  if (auth.currentUser) {
    token = await auth.currentUser.getIdToken();
  }

  const headers = { ...options.headers };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  return fetch(url, { ...options, headers });
};
