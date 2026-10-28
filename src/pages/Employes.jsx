import { AutoComplete, Col, Form, Input, Row } from 'antd';
import CrudPage from '../components/CrudPage';
import useFetch from '../hooks/useFetch';
import { departementApi, employeApi } from '../api';

const columns = [
  { title: 'Matricule', dataIndex: 'matricule', sorter: (a, b) => a.matricule.localeCompare(b.matricule) },
  { title: 'CIN', dataIndex: 'cin' },
  { title: 'Nom', dataIndex: 'nom', sorter: (a, b) => a.nom.localeCompare(b.nom) },
  { title: 'Prénoms', dataIndex: 'prenoms' },
  { title: 'Département', dataIndex: 'departement' },
  { title: 'Fonction', dataIndex: 'fonction' },
  { title: 'Téléphone', dataIndex: 'telephone' },
  { title: 'Adresse', dataIndex: 'adresse' },
];

const requis = (message) => [{ required: true, message }];

const Employes = () => {
  const employes = useFetch(employeApi.getAll);
  const departements = useFetch(departementApi.getAll);

  // Le département d'un employé est un texte libre : on suggère les départements existants
  const optionsDepartements = departements.data.map((d) => ({ value: d.nomDepartement }));

  return (
    <CrudPage
      title="Employés"
      nouveau="Nouvel employé"
      modifier="Modifier l'employé"
      supprimer="Supprimer cet employé ?"
      api={employeApi}
      columns={columns}
      rows={employes.data}
      loading={employes.loading}
      error={employes.error}
      reload={employes.reload}
      width={640}
    >
      {() => (
        <Row gutter={16}>
          <Col xs={24} sm={12}>
            <Form.Item name="matricule" label="Matricule" rules={requis('Le matricule est obligatoire')}>
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="cin" label="CIN" rules={requis('Le CIN est obligatoire')}>
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="nom" label="Nom" rules={requis('Le nom est obligatoire')}>
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="prenoms" label="Prénoms" rules={requis('Les prénoms sont obligatoires')}>
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="departement" label="Département" rules={requis('Le département est obligatoire')}>
              <AutoComplete
                options={optionsDepartements}
                placeholder="Choisir ou saisir"
                filterOption={(saisie, option) =>
                  option.value.toLowerCase().includes(saisie.toLowerCase())
                }
              />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="fonction" label="Fonction" rules={requis('La fonction est obligatoire')}>
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="telephone" label="Téléphone">
              <Input />
            </Form.Item>
          </Col>
          <Col xs={24} sm={12}>
            <Form.Item name="adresse" label="Adresse">
              <Input />
            </Form.Item>
          </Col>
        </Row>
      )}
    </CrudPage>
  );
};

export default Employes;
