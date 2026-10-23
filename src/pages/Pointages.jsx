import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { pointageApi } from '../api';
import { coche } from '../utils/format';

// Le backend renvoie l'employé lié sous la clé "Employe"
const columns = [
  { header: 'Matricule', render: (p) => p.Employe?.matricule },
  { header: 'Employé', render: (p) => (p.Employe ? `${p.Employe.nom} ${p.Employe.prenoms}` : '') },
  { header: 'Date', accessor: 'date' },
  { header: 'Arrivée matin', render: (p) => coche(p.arriveeMatin) },
  { header: 'Départ matin', render: (p) => coche(p.departMatin) },
  { header: 'Arrivée après-midi', render: (p) => coche(p.arriveeApresMidi) },
  { header: 'Départ après-midi', render: (p) => coche(p.departApresMidi) },
];

const Pointages = () => {
  const { data, loading, error } = useFetch(pointageApi.getAll);

  return (
    <>
      <h1>Pointages</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Pointages;
