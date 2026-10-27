import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { departementApi } from '../api';

const columns = [
  { header: 'Département', accessor: 'nomDepartement' },
  { header: 'Chef de département', accessor: 'chefDepartement' },
  { header: "Nombre d'employés", accessor: 'nombreEmploye' },
];

const Departements = () => {
  const { data, loading, error } = useFetch(departementApi.getAll);

  return (
    <>
      <h1>Départements</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Departements;
