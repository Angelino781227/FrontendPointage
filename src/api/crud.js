import client from './client';

// Fabrique les 5 opérations CRUD d'une ressource du backend
export const createCrudApi = (resource) => ({
  getAll: (params) => client.get(`/${resource}`, { params }).then((res) => res.data),
  getById: (id) => client.get(`/${resource}/${id}`).then((res) => res.data),
  create: (data) => client.post(`/${resource}`, data).then((res) => res.data),
  update: (id, data) => client.put(`/${resource}/${id}`, data).then((res) => res.data),
  remove: (id) => client.delete(`/${resource}/${id}`).then((res) => res.data),
});
