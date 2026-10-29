#!/bin/bash
# Adapte le frontend au backend modifie :
#  - cle primaire des departements = departementId, employes lies a un departement (departementId)
#  - ajout d'un departement : saisie du nom et du matricule du chef (employe cree automatiquement)
#  - modification d'un departement : liste deroulante des employes du departement pour choisir le chef
# A executer depuis la racine du projet React (apres setup-forms-calendar.sh)
# Utilisation : bash setup-departements-chef.sh
# Ecrase : DataTable, CrudPage, pages Departements/Employes/Users ; corrige une ligne de Signup.jsx

if [ ! -f package.json ] || [ ! -d src/pages ]; then
  echo "Erreur : lance ce script depuis la racine du projet React."
  exit 1
fi

manquants=""
for f in src/components/DataTable.jsx src/components/CrudPage.jsx src/components/FormModal.jsx \
         src/pages/Departements.jsx src/pages/Employes.jsx src/pages/Users.jsx src/pages/Signup.jsx \
         src/api/index.js src/hooks/useFetch.js src/utils/format.js; do
  [ -f "$f" ] || manquants="$manquants\n  - $f"
done
if [ -n "$manquants" ]; then
  echo "Erreur : fichiers manquants (crees par les scripts precedents) :"
  printf "$manquants\n"
  echo ""
  echo "Lance d'abord, dans l'ordre : setup-frontend.sh, setup-auth-pages.sh, setup-ui-antd.sh, setup-forms-calendar.sh"
  echo "puis relance ce script. Rien n'a ete modifie."
  exit 1
fi

echo "Creation de src/components/DataTable.jsx (cle de ligne configurable)..."
cat > src/components/DataTable.jsx << 'FILE_EOF'
import { Alert, Table, Typography } from 'antd';

// columns : colonnes Ant Design [{ title, dataIndex, render, sorter }]
// extra : élément affiché à droite du titre (ex. bouton d'ajout)
// rowKey : nom de la clé primaire des lignes ('id' par défaut)
const DataTable = ({ title, extra, columns, rows, loading, error, rowKey = 'id' }) => (
  <>
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 8,
        marginBottom: 16,
      }}
    >
      <Typography.Title level={2} style={{ margin: 0 }}>
        {title}
      </Typography.Title>
      {extra}
    </div>

    {error && (
      <Alert
        type="error"
        showIcon
        message="Erreur de chargement"
        description={error}
        style={{ marginBottom: 16 }}
      />
    )}

    <Table
      rowKey={rowKey}
      columns={columns}
      dataSource={rows}
      loading={loading}
      pagination={{ pageSize: 10, hideOnSinglePage: true }}
      scroll={{ x: 'max-content' }}
    />
  </>
);

export default DataTable;
FILE_EOF

echo "Creation de src/components/CrudPage.jsx (idKey, enregistrement passe au formulaire)..."
cat > src/components/CrudPage.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Button, Popconfirm, Space, message } from 'antd';
import { DeleteOutlined, EditOutlined, PlusOutlined } from '@ant-design/icons';
import DataTable from './DataTable';
import FormModal from './FormModal';

const VIDE = {};

// Page de liste avec ajout, modification et suppression.
// idKey : nom de la clé primaire ('id' par défaut, 'departementId' pour les départements)
// children : fonction (estEdition, enregistrement) => champs du formulaire (Form.Item)
// toPayload : (valeurs, estEdition, enregistrement) => corps de la requête envoyée au backend
const CrudPage = ({
  title,
  nouveau,
  modifier,
  supprimer = 'Supprimer cet élément ?',
  api,
  idKey = 'id',
  columns,
  rows,
  loading,
  error,
  reload,
  valeursParDefaut = VIDE,
  toPayload,
  width,
  children,
}) => {
  const [messageApi, contextHolder] = message.useMessage();
  const [modal, setModal] = useState({ open: false, record: null });

  const estEdition = modal.record !== null;
  const fermer = () => setModal((m) => ({ ...m, open: false }));

  const handleSubmit = async (values) => {
    const payload = toPayload ? toPayload(values, estEdition, modal.record) : values;
    if (estEdition) {
      await api.update(modal.record[idKey], payload);
    } else {
      await api.create(payload);
    }
    messageApi.success(estEdition ? 'Modifications enregistrées' : 'Création effectuée');
    fermer();
    reload();
  };

  const handleSuppression = async (record) => {
    try {
      await api.remove(record[idKey]);
      messageApi.success('Suppression effectuée');
      reload();
    } catch (err) {
      messageApi.error(err.message);
    }
  };

  const colonneActions = {
    title: 'Actions',
    key: 'actions',
    fixed: 'right',
    render: (_, record) => (
      <Space>
        <Button
          size="small"
          icon={<EditOutlined />}
          aria-label="Modifier"
          onClick={() => setModal({ open: true, record })}
        />
        <Popconfirm
          title={supprimer}
          okText="Supprimer"
          cancelText="Annuler"
          okButtonProps={{ danger: true }}
          onConfirm={() => handleSuppression(record)}
        >
          <Button size="small" danger icon={<DeleteOutlined />} aria-label="Supprimer" />
        </Popconfirm>
      </Space>
    ),
  };

  return (
    <>
      {contextHolder}
      <DataTable
        title={title}
        rowKey={idKey}
        extra={
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => setModal({ open: true, record: null })}
          >
            {nouveau}
          </Button>
        }
        columns={[...columns, colonneActions]}
        rows={rows}
        loading={loading}
        error={error}
      />
      <FormModal
        open={modal.open}
        title={estEdition ? modifier : nouveau}
        okText={estEdition ? 'Enregistrer' : 'Créer'}
        width={width}
        initialValues={modal.record ?? valeursParDefaut}
        onCancel={fermer}
        onSubmit={handleSubmit}
      >
        {children(estEdition, modal.record)}
      </FormModal>
    </>
  );
};

export default CrudPage;
FILE_EOF

echo "Creation de src/pages/Departements.jsx (chef a la creation, liste des employes a la modification)..."
cat > src/pages/Departements.jsx << 'FILE_EOF'
import { useMemo } from 'react';
import { Divider, Form, Input, InputNumber, Select } from 'antd';
import CrudPage from '../components/CrudPage';
import useFetch from '../hooks/useFetch';
import { departementApi, employeApi } from '../api';

const VALEURS_PAR_DEFAUT = { nombreEmploye: 0 };

const libelleEmploye = (e) => `${e.matricule} — ${e.nom} ${e.prenoms ?? ''}`.trim();

const Departements = () => {
  const departements = useFetch(departementApi.getAll);
  const employes = useFetch(employeApi.getAll);

  const employeParId = useMemo(
    () => Object.fromEntries(employes.data.map((e) => [e.id, e])),
    [employes.data]
  );

  // Créer un département crée aussi un employé : on recharge donc les deux listes
  const recharger = () => {
    departements.reload();
    employes.reload();
  };

  const columns = [
    {
      title: 'Département',
      dataIndex: 'nomDepartement',
      sorter: (a, b) => a.nomDepartement.localeCompare(b.nomDepartement),
    },
    {
      title: 'Chef',
      key: 'chef',
      render: (_, d) => {
        const chef = employeParId[d.chefDepartementId];
        return chef ? libelleEmploye(chef) : d.chefDepartement;
      },
    },
    {
      title: "Nombre d'employés",
      dataIndex: 'nombreEmploye',
      align: 'right',
      sorter: (a, b) => a.nombreEmploye - b.nombreEmploye,
    },
  ];

  // Corps envoyé au backend :
  //  - création : le backend crée l'employé chef à partir de `nom` et `matricule`
  //  - modification : on envoie l'id de l'employé choisi comme chef
  const toPayload = (values, estEdition) => {
    const commun = { nomDepartement: values.nomDepartement, nombreEmploye: values.nombreEmploye };

    if (!estEdition) {
      return { ...commun, chefDepartement: values.nom, nom: values.nom, matricule: values.matricule };
    }

    const chef = employeParId[values.chefDepartementId];
    return {
      ...commun,
      chefDepartementId: values.chefDepartementId ?? null,
      ...(chef && { chefDepartement: chef.nom }),
    };
  };

  const champsCommuns = (
    <>
      <Form.Item
        name="nomDepartement"
        label="Nom du département"
        rules={[{ required: true, message: 'Le nom du département est obligatoire' }]}
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
  );

  return (
    <CrudPage
      title="Départements"
      nouveau="Nouveau département"
      modifier="Modifier le département"
      supprimer="Supprimer ce département ? (impossible s'il contient encore des employés)"
      api={departementApi}
      idKey="departementId"
      columns={columns}
      rows={departements.data}
      loading={departements.loading}
      error={departements.error}
      reload={recharger}
      valeursParDefaut={VALEURS_PAR_DEFAUT}
      toPayload={toPayload}
    >
      {(estEdition, record) =>
        estEdition ? (
          <>
            {champsCommuns}
            <Form.Item
              name="chefDepartementId"
              label="Chef de département"
              extra="Choisis le chef parmi les employés de ce département"
            >
              <Select
                allowClear
                showSearch
                optionFilterProp="label"
                placeholder="Choisir un employé"
                loading={employes.loading}
                notFoundContent="Aucun employé dans ce département"
                options={employes.data
                  .filter((e) => e.departementId === record.departementId)
                  .map((e) => ({ value: e.id, label: libelleEmploye(e) }))}
              />
            </Form.Item>
          </>
        ) : (
          <>
            {champsCommuns}
            <Divider orientation="left" plain>
              Chef de département (employé créé automatiquement)
            </Divider>
            <Form.Item
              name="nom"
              label="Nom du chef"
              rules={[{ required: true, message: 'Le nom du chef est obligatoire' }]}
            >
              <Input />
            </Form.Item>
            <Form.Item
              name="matricule"
              label="Matricule du chef"
              rules={[{ required: true, message: 'Le matricule du chef est obligatoire' }]}
            >
              <Input />
            </Form.Item>
          </>
        )
      }
    </CrudPage>
  );
};

export default Departements;
FILE_EOF

echo "Creation de src/pages/Employes.jsx (departement choisi par son nom, departementId envoye)..."
cat > src/pages/Employes.jsx << 'FILE_EOF'
import { Col, Form, Input, Row, Select } from 'antd';
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

  // L'utilisateur voit le nom du département ; on envoie son id (departementId, obligatoire)
  // et le nom, qui reste aussi stocké dans l'employé.
  const toPayload = (values) => {
    const departement = departements.data.find((d) => d.departementId === values.departementId);
    return { ...values, departement: departement?.nomDepartement };
  };

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
      toPayload={toPayload}
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
            <Form.Item name="departementId" label="Département" rules={requis('Le département est obligatoire')}>
              <Select
                showSearch
                optionFilterProp="label"
                placeholder="Choisir un département"
                loading={departements.loading}
                notFoundContent="Crée d'abord un département"
                options={departements.data.map((d) => ({
                  value: d.departementId,
                  label: d.nomDepartement,
                }))}
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
FILE_EOF

echo "Creation de src/pages/Users.jsx (departements identifies par departementId)..."
cat > src/pages/Users.jsx << 'FILE_EOF'
import { useMemo } from 'react';
import { Form, Input, Select, Switch, Tag } from 'antd';
import CrudPage from '../components/CrudPage';
import useFetch from '../hooks/useFetch';
import { departementApi, userApi } from '../api';
import { libelleRole } from '../utils/format';

const VALEURS_PAR_DEFAUT = { userRole: false };

// À la modification, un mot de passe laissé vide conserve l'ancien
const toPayload = (values) => {
  const payload = { ...values };
  if (!payload.userPassword) delete payload.userPassword;
  return payload;
};

const Users = () => {
  const users = useFetch(userApi.getAll);
  const departements = useFetch(departementApi.getAll);

  // Associe l'id du département (userBranch) à son nom
  const nomsDepartements = useMemo(
    () => Object.fromEntries(departements.data.map((d) => [d.departementId, d.nomDepartement])),
    [departements.data]
  );

  const columns = [
    { title: 'Identifiant', dataIndex: 'userLogin', sorter: (a, b) => a.userLogin.localeCompare(b.userLogin) },
    {
      title: 'Rôle',
      dataIndex: 'userRole',
      render: (estAdmin) => <Tag color={estAdmin ? 'blue' : 'default'}>{libelleRole(estAdmin)}</Tag>,
    },
    {
      title: 'Département',
      dataIndex: 'userBranch',
      render: (id) => nomsDepartements[id] ?? id,
    },
  ];

  return (
    <CrudPage
      title="Utilisateurs"
      nouveau="Nouvel utilisateur"
      modifier="Modifier l'utilisateur"
      supprimer="Supprimer cet utilisateur ?"
      api={userApi}
      columns={columns}
      rows={users.data}
      loading={users.loading}
      error={users.error}
      reload={users.reload}
      valeursParDefaut={VALEURS_PAR_DEFAUT}
      toPayload={toPayload}
    >
      {(estEdition) => (
        <>
          <Form.Item
            name="userLogin"
            label="Identifiant"
            rules={[
              { required: true, message: "L'identifiant est obligatoire" },
              { min: 3, message: "L'identifiant doit contenir au moins 3 caractères" },
            ]}
          >
            <Input autoComplete="off" />
          </Form.Item>

          <Form.Item
            name="userBranch"
            label="Département"
            rules={[{ required: true, message: 'Le département est obligatoire' }]}
          >
            <Select
              placeholder="Choisir un département"
              loading={departements.loading}
              options={departements.data.map((d) => ({ value: d.departementId, label: d.nomDepartement }))}
            />
          </Form.Item>

          <Form.Item
            name="userPassword"
            label="Mot de passe"
            extra={estEdition ? "Laisse vide pour conserver le mot de passe actuel" : undefined}
            rules={[
              { required: !estEdition, message: 'Le mot de passe est obligatoire' },
              { min: 8, message: 'Le mot de passe doit contenir au moins 8 caractères' },
            ]}
          >
            <Input.Password autoComplete="new-password" />
          </Form.Item>

          <Form.Item name="userRole" label="Administrateur" valuePropName="checked">
            <Switch checkedChildren="Oui" unCheckedChildren="Non" />
          </Form.Item>
        </>
      )}
    </CrudPage>
  );
};

export default Users;
FILE_EOF

# Signup.jsx : la liste des departements utilise departementId (une seule ligne a corriger)
if grep -q 'value: d\.id, label: d\.nomDepartement' src/pages/Signup.jsx; then
  sed -i 's/value: d\.id, label: d\.nomDepartement/value: d.departementId, label: d.nomDepartement/' src/pages/Signup.jsx
  echo "Signup.jsx corrige (departementId)."
else
  echo "Signup.jsx : deja adapte (ou modifie), rien a faire."
fi

echo ""
echo "Frontend adapte aux departements avec chef avec succes !"
echo "Lance : npm run dev"