import axios from 'axios';

const client = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
  headers: { 'Content-Type': 'application/json' },
});

// Remonte le message d'erreur renvoyé par le backend (errorHandler)
client.interceptors.response.use(
  (response) => response,
  (error) => {
    const message = error.response?.data?.message || error.message || 'Erreur réseau';
    return Promise.reject(new Error(message));
  }
);

export default client;
