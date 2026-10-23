import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { userApi } from '../api';
import { libelleRole } from '../utils/format';

const columns = [
  { header: 'Identifiant', accessor: 'userLogin' },
  { header: 'Rôle', render: (u) => libelleRole(u.userRole) },
  { header: 'Département (id)', accessor: 'userBranch' },
];

const Users = () => {
  const { data, loading, error } = useFetch(userApi.getAll);

  return (
    <>
      <h1>Utilisateurs</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Users;
