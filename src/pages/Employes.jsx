import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { employeApi } from '../api';

const columns = [
  { header: 'Matricule', accessor: 'matricule' },
  { header: 'CIN', accessor: 'cin' },
  { header: 'Nom', accessor: 'nom' },
  { header: 'Prénoms', accessor: 'prenoms' },
  { header: 'Département', accessor: 'departement' },
  { header: 'Fonction', accessor: 'fonction' },
  { header: 'Téléphone', accessor: 'telephone' },
  { header: 'Adresse', accessor: 'adresse' },
];

const Employes = () => {
  const { data, loading, error } = useFetch(employeApi.getAll);

  return (
    <>
      <h1>Employés</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Employes;
