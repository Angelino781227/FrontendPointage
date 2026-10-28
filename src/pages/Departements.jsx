import { Form, Input, InputNumber } from 'antd';
import CrudPage from '../components/CrudPage';
import useFetch from '../hooks/useFetch';
import { departementApi } from '../api';

const columns = [
  {
    title: 'Département',
    dataIndex: 'nomDepartement',
    sorter: (a, b) => a.nomDepartement.localeCompare(b.nomDepartement),
  },
  { title: 'Chef', dataIndex: 'chefDepartement' },
  {
    title: "Nombre d'employés",
    dataIndex: 'nombreEmploye',
    align: 'right',
    sorter: (a, b) => a.nombreEmploye - b.nombreEmploye,
  },
];

const VALEURS_PAR_DEFAUT = { nombreEmploye: 0 };

const Departements = () => {
  const departements = useFetch(departementApi.getAll);

  return (
    <CrudPage
      title="Départements"
      nouveau="Nouveau département"
      modifier="Modifier le département"
      supprimer="Supprimer ce département ?"
      api={departementApi}
      columns={columns}
      rows={departements.data}
      loading={departements.loading}
      error={departements.error}
      reload={departements.reload}
      valeursParDefaut={VALEURS_PAR_DEFAUT}
    >
      {() => (
        <>
          <Form.Item
            name="nomDepartement"
            label="Nom du département"
            rules={[{ required: true, message: 'Le nom du département est obligatoire' }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            name="chefDepartement"
            label="Chef de département"
            rules={[{ required: true, message: 'Le chef de département est obligatoire' }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            name="nombreEmploye"
            label="Nombre d'employés"
            rules={[{ required: true, message: "Indique le nombre d'employés" }]}
          >
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
        </>
      )}
    </CrudPage>
  );
};

export default Departements;
