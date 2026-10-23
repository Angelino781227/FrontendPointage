import { createCrudApi } from './crud';

export const departementApi = createCrudApi('departements');
export const employeApi = createCrudApi('employes');
export const pointageApi = createCrudApi('pointages'); // getAll({ employe, date })
export const userApi = createCrudApi('users');
