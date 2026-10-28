#!/bin/bash
# Ajoute au frontend : formulaires d'ajout/modification/suppression, page Pointages en calendrier
# (clic sur une date = pointages du jour) et redirection de l'entree de l'appli vers le login.
# A executer depuis la racine du projet React (apres setup-ui-antd.sh)
# Utilisation : bash setup-forms-calendar.sh
# Ecrase : App.jsx, Layout, DataTable, Login et les pages Employes/Departements/Users/Pointages
# Ne touche pas : main.jsx, Accueil*, Signup, src/api/, src/hooks/

if [ ! -f package.json ] || [ ! -d src/pages ] || [ ! -d node_modules/antd ]; then
  echo "Erreur : lance ce script depuis la racine du projet React, apres setup-ui-antd.sh (antd doit etre installe)."
  exit 1
fi

# Fichiers crees par les scripts precedents et necessaires a App.jsx / aux pages
manquants=""
for f in src/pages/Accueil.jsx src/pages/AccueilAdmin.jsx src/pages/AccueilUtilisateur.jsx \
         src/pages/Signup.jsx src/api/index.js src/hooks/useFetch.js src/utils/format.js; do
  [ -f "$f" ] || manquants="$manquants\n  - $f"
done
if [ -n "$manquants" ]; then
  echo "Erreur : fichiers manquants (crees par les scripts precedents) :"
  printf "$manquants\n"
  echo ""
  echo "Lance d'abord, dans l'ordre : setup-frontend.sh, setup-auth-pages.sh, setup-ui-antd.sh"
  echo "puis relance ce script. Rien n'a ete modifie."
  exit 1
fi

echo "Creation de src/App.jsx (login en page d'entree)..."
cat > src/App.jsx << 'FILE_EOF'
import { Navigate, Route, Routes } from 'react-router-dom';
import Layout from './components/Layout';
import Accueil from './pages/Accueil';
import Departements from './pages/Departements';
import Employes from './pages/Employes';
import Login from './pages/Login';
import Pointages from './pages/Pointages';
import Signup from './pages/Signup';
import Users from './pages/Users';

const App = () => (
  <Routes>
    {/* L'application s'ouvre sur la page de connexion */}
    <Route path="/" element={<Navigate to="/login" replace />} />
    <Route path="/login" element={<Login />} />
    <Route path="/signup" element={<Signup />} />

    {/* Pages de l'application, avec le menu */}
    {/* TODO: protéger ces routes une fois l'authentification en place */}
    <Route element={<Layout />}>
      <Route path="/accueil" element={<Accueil />} />
      <Route path="/employes" element={<Employes />} />
      <Route path="/pointages" element={<Pointages />} />
      <Route path="/departements" element={<Departements />} />
      <Route path="/users" element={<Users />} />
    </Route>

    {/* Toute adresse inconnue renvoie vers la connexion */}
    <Route path="*" element={<Navigate to="/login" replace />} />
  </Routes>
);

export default App;
FILE_EOF

echo "Creation de src/components/Layout.jsx..."
cat > src/components/Layout.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { Button, Layout as AntLayout, Menu, theme } from 'antd';
import {
  ApartmentOutlined,
  CalendarOutlined,
  HomeOutlined,
  LogoutOutlined,
  TeamOutlined,
  UserOutlined,
} from '@ant-design/icons';

const { Header, Sider, Content } = AntLayout;

const items = [
  { key: '/accueil', icon: <HomeOutlined />, label: 'Accueil' },
  { key: '/employes', icon: <TeamOutlined />, label: 'Employés' },
  { key: '/pointages', icon: <CalendarOutlined />, label: 'Pointages' },
  { key: '/departements', icon: <ApartmentOutlined />, label: 'Départements' },
  { key: '/users', icon: <UserOutlined />, label: 'Utilisateurs' },
];

const Layout = () => {
  const [collapsed, setCollapsed] = useState(false);
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const { token } = theme.useToken();

  const handleDeconnexion = () => {
    // TODO: supprimer la session de l'utilisateur (à implémenter avec l'authentification)
    navigate('/login');
  };

  return (
    <AntLayout style={{ minHeight: '100vh' }}>
      <Sider collapsible collapsed={collapsed} onCollapse={setCollapsed} breakpoint="lg">
        <div
          style={{
            height: 48,
            margin: 16,
            color: '#fff',
            fontWeight: 600,
            lineHeight: '48px',
            textAlign: 'center',
            overflow: 'hidden',
            whiteSpace: 'nowrap',
          }}
        >
          {collapsed ? 'GP' : 'Gestion de pointage'}
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[pathname]}
          items={items}
          onClick={({ key }) => navigate(key)}
        />
      </Sider>

      <AntLayout>
        <Header
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
            padding: '0 24px',
            background: token.colorBgContainer,
          }}
        >
          <Button icon={<LogoutOutlined />} onClick={handleDeconnexion}>
            Déconnexion
          </Button>
        </Header>
        <Content style={{ margin: 24 }}>
          <Outlet />
        </Content>
      </AntLayout>
    </AntLayout>
  );
};

export default Layout;
FILE_EOF

echo "Creation de src/components/DataTable.jsx..."
cat > src/components/DataTable.jsx << 'FILE_EOF'
import { Alert, Table, Typography } from 'antd';

// columns : colonnes Ant Design [{ title, dataIndex, render, sorter }]
// extra : élément affiché à droite du titre (ex. bouton d'ajout)
const DataTable = ({ title, extra, columns, rows, loading, error }) => (
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
      rowKey="id"
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

echo "Creation de src/components/FormModal.jsx..."
cat > src/components/FormModal.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Alert, Button, Form, Modal, Space } from 'antd';

// Le formulaire n'existe que pendant que la fenêtre est ouverte :
// il repart donc toujours des bonnes valeurs initiales (création ou modification).
const FormBody = ({ initialValues, okText, onCancel, onSubmit, children }) => {
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  const handleFinish = async (values) => {
    setSaving(true);
    setError(null);
    try {
      await onSubmit(values);
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Form layout="vertical" requiredMark={false} initialValues={initialValues} onFinish={handleFinish}>
      {error && <Alert type="error" showIcon message={error} style={{ marginBottom: 16 }} />}
      {children}
      <Form.Item style={{ marginBottom: 0, textAlign: 'right' }}>
        <Space>
          <Button onClick={onCancel}>Annuler</Button>
          <Button type="primary" htmlType="submit" loading={saving}>
            {okText}
          </Button>
        </Space>
      </Form.Item>
    </Form>
  );
};

// onSubmit(valeurs) doit lever une erreur en cas d'échec : son message s'affiche dans la fenêtre.
const FormModal = ({ open, title, width = 520, onCancel, ...reste }) => (
  <Modal open={open} title={title} width={width} footer={null} onCancel={onCancel} maskClosable={false}>
    {open && <FormBody onCancel={onCancel} {...reste} />}
  </Modal>
);

export default FormModal;
FILE_EOF

echo "Creation de src/components/CrudPage.jsx..."
cat > src/components/CrudPage.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Button, Popconfirm, Space, message } from 'antd';
import { DeleteOutlined, EditOutlined, PlusOutlined } from '@ant-design/icons';
import DataTable from './DataTable';
import FormModal from './FormModal';

const VIDE = {};

// Page de liste avec ajout, modification et suppression.
// children : fonction (estEdition) => champs du formulaire (Form.Item)
const CrudPage = ({
  title,
  nouveau,
  modifier,
  supprimer = 'Supprimer cet élément ?',
  api,
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
    const payload = toPayload ? toPayload(values, estEdition) : values;
    if (estEdition) {
      await api.update(modal.record.id, payload);
    } else {
      await api.create(payload);
    }
    messageApi.success(estEdition ? 'Modifications enregistrées' : 'Création effectuée');
    fermer();
    reload();
  };

  const handleSuppression = async (record) => {
    try {
      await api.remove(record.id);
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
        {children(estEdition)}
      </FormModal>
    </>
  );
};

export default CrudPage;
FILE_EOF

echo "Creation de src/pages/Login.jsx..."
cat > src/pages/Login.jsx << 'FILE_EOF'
import { Link, useNavigate } from 'react-router-dom';
import { Button, Card, Form, Input, Typography } from 'antd';
import { LockOutlined, UserOutlined } from '@ant-design/icons';

const Login = () => {
  const navigate = useNavigate();

  const handleFinish = () => {
    // TODO: appeler l'API de connexion et vérifier les identifiants (à implémenter).
    // Temporaire : redirige vers l'accueil sans aucune vérification.
    navigate('/accueil');
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', padding: 16 }}>
      <Card style={{ width: 400, maxWidth: '100%' }}>
        <Typography.Title level={3} style={{ textAlign: 'center' }}>
          Connexion
        </Typography.Title>

        <Form layout="vertical" onFinish={handleFinish} requiredMark={false}>
          <Form.Item
            name="userLogin"
            label="Identifiant"
            rules={[{ required: true, message: 'Saisis ton identifiant' }]}
          >
            <Input prefix={<UserOutlined />} autoComplete="username" />
          </Form.Item>

          <Form.Item
            name="userPassword"
            label="Mot de passe"
            rules={[{ required: true, message: 'Saisis ton mot de passe' }]}
          >
            <Input.Password prefix={<LockOutlined />} autoComplete="current-password" />
          </Form.Item>

          <Button type="primary" htmlType="submit" block>
            Se connecter
          </Button>
        </Form>

        <Typography.Paragraph style={{ marginTop: 16, marginBottom: 0, textAlign: 'center' }}>
          Pas encore de compte ? <Link to="/signup">Créer un compte</Link>
        </Typography.Paragraph>
      </Card>
    </div>
  );
};

export default Login;
FILE_EOF

echo "Creation de src/pages/Employes.jsx..."
cat > src/pages/Employes.jsx << 'FILE_EOF'
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
FILE_EOF

echo "Creation de src/pages/Departements.jsx..."
cat > src/pages/Departements.jsx << 'FILE_EOF'
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
FILE_EOF

echo "Creation de src/pages/Users.jsx..."
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
    () => Object.fromEntries(departements.data.map((d) => [d.id, d.nomDepartement])),
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
              options={departements.data.map((d) => ({ value: d.id, label: d.nomDepartement }))}
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

echo "Creation de src/pages/Pointages.jsx (calendrier)..."
cat > src/pages/Pointages.jsx << 'FILE_EOF'
import { useMemo, useState } from 'react';
import {
  Alert,
  Badge,
  Button,
  Calendar,
  Card,
  Drawer,
  Form,
  Popconfirm,
  Select,
  Space,
  Switch,
  Table,
  Tag,
  Typography,
  message,
} from 'antd';
import { DeleteOutlined, EditOutlined, PlusOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import FormModal from '../components/FormModal';
import useFetch from '../hooks/useFetch';
import { employeApi, pointageApi } from '../api';

const FORMAT_CLE = 'YYYY-MM-DD';

const CASES = [
  { cle: 'arriveeMatin', label: 'Arrivée matin' },
  { cle: 'departMatin', label: 'Départ matin' },
  { cle: 'arriveeApresMidi', label: 'Arrivée après-midi' },
  { cle: 'departApresMidi', label: 'Départ après-midi' },
];

const STATUTS = {
  complet: { cle: 'complet', status: 'success', label: 'Complet' },
  partiel: { cle: 'partiel', status: 'warning', label: 'Partiel' },
  absent: { cle: 'absent', status: 'error', label: 'Absent' },
};

const VALEURS_PAR_DEFAUT = Object.fromEntries(CASES.map((c) => [c.cle, false]));

// Complet = les 4 cases cochées, absent = aucune, partiel = entre les deux
const statutPointage = (pointage) => {
  const cochees = CASES.filter((c) => pointage[c.cle]).length;
  if (cochees === CASES.length) return STATUTS.complet;
  if (cochees === 0) return STATUTS.absent;
  return STATUTS.partiel;
};

// Le backend refuse les pointages du samedi et du dimanche
const estWeekEnd = (date) => date.day() === 0 || date.day() === 6;

const libelleEmploye = (e) => `${e.matricule} — ${e.nom} ${e.prenoms}`;

const Pointages = () => {
  const [messageApi, contextHolder] = message.useMessage();
  const pointages = useFetch(pointageApi.getAll);
  const employes = useFetch(employeApi.getAll);

  const [jour, setJour] = useState(dayjs());
  const [drawerOuvert, setDrawerOuvert] = useState(false);
  const [modal, setModal] = useState({ open: false, record: null });

  // Pointages regroupés par date (YYYY-MM-DD)
  const parDate = useMemo(() => {
    const groupes = {};
    pointages.data.forEach((p) => {
      if (!groupes[p.date]) groupes[p.date] = [];
      groupes[p.date].push(p);
    });
    return groupes;
  }, [pointages.data]);

  const cleJour = jour.format(FORMAT_CLE);
  const pointagesDuJour = parDate[cleJour] ?? [];
  const idsDejaPointes = new Set(pointagesDuJour.map((p) => p.employeId));
  const estEdition = modal.record !== null;

  // À la création, seuls les employés sans pointage ce jour-là sont proposés
  const employesProposes = estEdition
    ? employes.data
    : employes.data.filter((e) => !idsDejaPointes.has(e.id));

  const fermerModal = () => setModal((m) => ({ ...m, open: false }));

  const cellRender = (date, info) => {
    if (info.type !== 'date') return info.originNode;
    const liste = parDate[date.format(FORMAT_CLE)];
    if (!liste || liste.length === 0) return null;

    const compteurs = { complet: 0, partiel: 0, absent: 0 };
    liste.forEach((p) => {
      compteurs[statutPointage(p).cle] += 1;
    });

    return (
      <ul style={{ listStyle: 'none', margin: 0, padding: 0, fontSize: 12 }}>
        {Object.values(STATUTS)
          .filter((s) => compteurs[s.cle] > 0)
          .map((s) => (
            <li key={s.cle}>
              <Badge status={s.status} text={`${s.label} : ${compteurs[s.cle]}`} />
            </li>
          ))}
      </ul>
    );
  };

  const handleSelect = (date, info) => {
    // Ignore la navigation entre mois/années : seul un clic sur un jour ouvre le détail
    if (info?.source && info.source !== 'date') return;
    setJour(date);
    setDrawerOuvert(true);
  };

  const handleSubmit = async (values) => {
    if (estEdition) {
      // L'employé et la date d'un pointage ne changent pas : on n'envoie que les cases
      const cases = Object.fromEntries(CASES.map((c) => [c.cle, values[c.cle]]));
      await pointageApi.update(modal.record.id, cases);
    } else {
      await pointageApi.create({ ...values, date: cleJour });
    }
    messageApi.success(estEdition ? 'Pointage modifié' : 'Pointage enregistré');
    fermerModal();
    pointages.reload();
  };

  const handleSuppression = async (pointage) => {
    try {
      await pointageApi.remove(pointage.id);
      messageApi.success('Pointage supprimé');
      pointages.reload();
    } catch (err) {
      messageApi.error(err.message);
    }
  };

  const colonnes = [
    {
      title: 'Employé',
      key: 'employe',
      render: (_, p) => (p.Employe ? libelleEmploye(p.Employe) : p.employeId),
    },
    ...CASES.map((c) => ({
      title: c.label,
      dataIndex: c.cle,
      align: 'center',
      render: (valeur) => <Tag color={valeur ? 'green' : 'red'}>{valeur ? 'Oui' : 'Non'}</Tag>,
    })),
    {
      title: 'Statut',
      key: 'statut',
      render: (_, p) => {
        const { status, label } = statutPointage(p);
        return <Badge status={status} text={label} />;
      },
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_, p) => (
        <Space>
          <Button
            size="small"
            icon={<EditOutlined />}
            aria-label="Modifier"
            onClick={() => setModal({ open: true, record: p })}
          />
          <Popconfirm
            title="Supprimer ce pointage ?"
            okText="Supprimer"
            cancelText="Annuler"
            okButtonProps={{ danger: true }}
            onConfirm={() => handleSuppression(p)}
          >
            <Button size="small" danger icon={<DeleteOutlined />} aria-label="Supprimer" />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const erreur = pointages.error || employes.error;

  return (
    <>
      {contextHolder}
      <Typography.Title level={2}>Pointages</Typography.Title>

      {erreur && (
        <Alert
          type="error"
          showIcon
          message="Erreur de chargement"
          description={erreur}
          style={{ marginBottom: 16 }}
        />
      )}

      <Card style={{ marginBottom: 16 }}>
        <Space wrap size="large">
          <Typography.Text>Clique sur un jour pour voir ou saisir les pointages.</Typography.Text>
          {Object.values(STATUTS).map((s) => (
            <Badge key={s.cle} status={s.status} text={s.label} />
          ))}
        </Space>
      </Card>

      <Card>
        <Calendar cellRender={cellRender} disabledDate={estWeekEnd} onSelect={handleSelect} />
      </Card>

      <Drawer
        open={drawerOuvert}
        onClose={() => setDrawerOuvert(false)}
        width="min(900px, 100vw)"
        title={<span style={{ textTransform: 'capitalize' }}>{jour.format('dddd D MMMM YYYY')}</span>}
        extra={
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => setModal({ open: true, record: null })}
          >
            Ajouter un pointage
          </Button>
        }
      >
        <Typography.Paragraph type="secondary">
          {pointagesDuJour.length} pointage(s) enregistré(s) pour {employes.data.length} employé(s).
        </Typography.Paragraph>
        <Table
          rowKey="id"
          size="small"
          columns={colonnes}
          dataSource={pointagesDuJour}
          loading={pointages.loading}
          pagination={false}
          scroll={{ x: 'max-content' }}
          locale={{ emptyText: 'Aucun pointage enregistré ce jour-là' }}
        />
      </Drawer>

      <FormModal
        open={modal.open}
        title={estEdition ? 'Modifier le pointage' : 'Nouveau pointage'}
        okText={estEdition ? 'Enregistrer' : 'Créer'}
        initialValues={modal.record ?? VALEURS_PAR_DEFAUT}
        onCancel={fermerModal}
        onSubmit={handleSubmit}
      >
        <Form.Item
          name="employeId"
          label="Employé"
          rules={[{ required: true, message: 'Choisis un employé' }]}
        >
          <Select
            showSearch
            disabled={estEdition}
            optionFilterProp="label"
            placeholder="Choisir un employé"
            notFoundContent="Aucun employé disponible"
            options={employesProposes.map((e) => ({ value: e.id, label: libelleEmploye(e) }))}
          />
        </Form.Item>
        {CASES.map((c) => (
          <Form.Item key={c.cle} name={c.cle} label={c.label} valuePropName="checked">
            <Switch checkedChildren="Oui" unCheckedChildren="Non" />
          </Form.Item>
        ))}
      </FormModal>
    </>
  );
};

export default Pointages;
FILE_EOF

echo ""
echo "Formulaires, calendrier et redirection crees avec succes !"
echo "  /           -> redirige vers /login"
echo "  /login      -> connexion (redirige temporairement vers /accueil)"
echo "  /accueil    -> accueil selon le role"
echo "Lance : npm run dev"
