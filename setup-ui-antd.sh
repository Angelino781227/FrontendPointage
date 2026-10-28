#!/bin/bash
# Refait l'interface du frontend avec Ant Design (menu lateral, tableaux, formulaires, calendrier)
# A executer depuis la racine du projet React (apres setup-frontend.sh et setup-auth-pages.sh)
# Utilisation : bash setup-ui-antd.sh
# Ecrase : main.jsx, Layout, DataTable, pages Employes/Departements/Users/Pointages/Login/Signup/Accueil*
# Ne touche pas : App.jsx, Accueil.jsx, src/api/, src/hooks/

if [ ! -f package.json ] || [ ! -d src/pages ]; then
  echo "Erreur : lance ce script depuis la racine du projet React, apres setup-frontend.sh."
  exit 1
fi

echo "Verification des dependances (antd, icones, dayjs)..."
npm install antd @ant-design/icons dayjs

echo "Creation de src/main.jsx (locale francaise)..."
cat > src/main.jsx << 'FILE_EOF'
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { ConfigProvider } from 'antd';
import frFR from 'antd/locale/fr_FR';
import dayjs from 'dayjs';
import 'dayjs/locale/fr';
import App from './App';
import './styles/global.css';

dayjs.locale('fr');

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ConfigProvider locale={frFR} theme={{ token: { borderRadius: 8 } }}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </ConfigProvider>
  </StrictMode>
);
FILE_EOF

echo "Creation de src/styles/global.css..."
cat > src/styles/global.css << 'FILE_EOF'
body {
  margin: 0;
  background: #f5f6f8;
}
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
  LoginOutlined,
  TeamOutlined,
  UserOutlined,
} from '@ant-design/icons';

const { Header, Sider, Content } = AntLayout;

const items = [
  { key: '/', icon: <HomeOutlined />, label: 'Accueil' },
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
          <Button icon={<LoginOutlined />} onClick={() => navigate('/login')}>
            Connexion
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
const DataTable = ({ title, columns, rows, loading, error }) => (
  <>
    <Typography.Title level={2}>{title}</Typography.Title>
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

echo "Creation de src/pages/Employes.jsx..."
cat > src/pages/Employes.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { employeApi } from '../api';

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

const Employes = () => {
  const { data, loading, error } = useFetch(employeApi.getAll);

  return <DataTable title="Employés" columns={columns} rows={data} loading={loading} error={error} />;
};

export default Employes;
FILE_EOF

echo "Creation de src/pages/Departements.jsx..."
cat > src/pages/Departements.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
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

const Departements = () => {
  const { data, loading, error } = useFetch(departementApi.getAll);

  return (
    <DataTable title="Départements" columns={columns} rows={data} loading={loading} error={error} />
  );
};

export default Departements;
FILE_EOF

echo "Creation de src/pages/Users.jsx..."
cat > src/pages/Users.jsx << 'FILE_EOF'
import { useMemo } from 'react';
import { Tag } from 'antd';
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { departementApi, userApi } from '../api';
import { libelleRole } from '../utils/format';

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
    <DataTable
      title="Utilisateurs"
      columns={columns}
      rows={users.data}
      loading={users.loading}
      error={users.error}
    />
  );
};

export default Users;
FILE_EOF

echo "Creation de src/pages/Pointages.jsx (calendrier)..."
cat > src/pages/Pointages.jsx << 'FILE_EOF'
import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Badge,
  Calendar,
  Card,
  Col,
  Descriptions,
  Empty,
  Row,
  Select,
  Space,
  Spin,
  Tag,
  Typography,
} from 'antd';
import dayjs from 'dayjs';
import useFetch from '../hooks/useFetch';
import { employeApi, pointageApi } from '../api';

const FORMAT_CLE = 'YYYY-MM-DD';

const CASES = [
  { cle: 'arriveeMatin', label: 'Arrivée du matin' },
  { cle: 'departMatin', label: 'Départ du matin' },
  { cle: 'arriveeApresMidi', label: "Arrivée de l'après-midi" },
  { cle: 'departApresMidi', label: "Départ de l'après-midi" },
];

const STATUTS = {
  complet: { status: 'success', label: 'Complet' },
  partiel: { status: 'warning', label: 'Partiel' },
  absent: { status: 'error', label: 'Absent' },
};

// Complet = les 4 cases cochées, absent = aucune, partiel = entre les deux
const statutPointage = (pointage) => {
  const cochees = CASES.filter((c) => pointage[c.cle]).length;
  if (cochees === CASES.length) return STATUTS.complet;
  if (cochees === 0) return STATUTS.absent;
  return STATUTS.partiel;
};

// Le backend refuse les pointages du samedi et du dimanche
const estWeekEnd = (date) => date.day() === 0 || date.day() === 6;

const Pointages = () => {
  const employes = useFetch(employeApi.getAll);
  const [employeId, setEmployeId] = useState(null);
  const [jourSelectionne, setJourSelectionne] = useState(dayjs());

  // Sélectionne automatiquement le premier employé une fois la liste chargée
  useEffect(() => {
    if (employeId === null && employes.data.length > 0) setEmployeId(employes.data[0].id);
  }, [employes.data, employeId]);

  const chargerPointages = useCallback(
    () => (employeId ? pointageApi.getAll({ employe: employeId }) : Promise.resolve([])),
    [employeId]
  );
  const pointages = useFetch(chargerPointages);

  const parDate = useMemo(
    () => Object.fromEntries(pointages.data.map((p) => [p.date, p])),
    [pointages.data]
  );
  const pointageDuJour = parDate[jourSelectionne.format(FORMAT_CLE)];

  const cellRender = (date, info) => {
    if (info.type !== 'date') return info.originNode;
    const pointage = parDate[date.format(FORMAT_CLE)];
    if (!pointage) return null;
    const { status, label } = statutPointage(pointage);
    return <Badge status={status} text={label} />;
  };

  let detail;
  if (estWeekEnd(jourSelectionne)) {
    detail = <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="Week-end : pas de pointage" />;
  } else if (!pointageDuJour) {
    detail = (
      <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="Aucun pointage enregistré ce jour-là" />
    );
  } else {
    const { status, label } = statutPointage(pointageDuJour);
    detail = (
      <Space direction="vertical" style={{ width: '100%' }}>
        <Badge status={status} text={label} />
        <Descriptions column={1} bordered size="small">
          {CASES.map((c) => (
            <Descriptions.Item key={c.cle} label={c.label}>
              <Tag color={pointageDuJour[c.cle] ? 'green' : 'red'}>
                {pointageDuJour[c.cle] ? 'Oui' : 'Non'}
              </Tag>
            </Descriptions.Item>
          ))}
        </Descriptions>
      </Space>
    );
  }

  const erreur = employes.error || pointages.error;

  return (
    <>
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
          <Select
            showSearch
            style={{ minWidth: 300 }}
            placeholder="Choisir un employé"
            loading={employes.loading}
            value={employeId}
            onChange={setEmployeId}
            optionFilterProp="label"
            options={employes.data.map((e) => ({
              value: e.id,
              label: `${e.matricule} — ${e.nom} ${e.prenoms}`,
            }))}
          />
          <Space>
            {Object.values(STATUTS).map((s) => (
              <Badge key={s.label} status={s.status} text={s.label} />
            ))}
          </Space>
        </Space>
      </Card>

      <Row gutter={[16, 16]}>
        <Col xs={24} xl={17}>
          <Card>
            <Spin spinning={pointages.loading}>
              <Calendar
                cellRender={cellRender}
                disabledDate={estWeekEnd}
                onSelect={(date) => setJourSelectionne(date)}
              />
            </Spin>
          </Card>
        </Col>
        <Col xs={24} xl={7}>
          <Card
            title={
              <span style={{ textTransform: 'capitalize' }}>
                {jourSelectionne.format('dddd D MMMM YYYY')}
              </span>
            }
          >
            {detail}
          </Card>
        </Col>
      </Row>
    </>
  );
};

export default Pointages;
FILE_EOF

echo "Creation de src/pages/Login.jsx..."
cat > src/pages/Login.jsx << 'FILE_EOF'
import { Link } from 'react-router-dom';
import { Button, Card, Form, Input, Typography } from 'antd';
import { LockOutlined, UserOutlined } from '@ant-design/icons';

const Login = () => {
  const handleFinish = () => {
    // TODO: appeler l'API de connexion (à implémenter)
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

echo "Creation de src/pages/Signup.jsx..."
cat > src/pages/Signup.jsx << 'FILE_EOF'
import { Link } from 'react-router-dom';
import { Alert, Button, Card, Form, Input, Select, Typography } from 'antd';
import { LockOutlined, UserOutlined } from '@ant-design/icons';
import useFetch from '../hooks/useFetch';
import { departementApi } from '../api';

// Le rôle (userRole) n'est volontairement pas dans ce formulaire :
// il ne doit jamais être choisi par l'utilisateur lui-même à l'inscription.
const Signup = () => {
  const departements = useFetch(departementApi.getAll);

  const handleFinish = () => {
    // TODO: appeler l'API d'inscription (à implémenter)
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', padding: 16 }}>
      <Card style={{ width: 400, maxWidth: '100%' }}>
        <Typography.Title level={3} style={{ textAlign: 'center' }}>
          Créer un compte
        </Typography.Title>

        {departements.error && (
          <Alert
            type="warning"
            showIcon
            message="Départements indisponibles"
            description={departements.error}
            style={{ marginBottom: 16 }}
          />
        )}

        <Form layout="vertical" onFinish={handleFinish} requiredMark={false}>
          <Form.Item
            name="userLogin"
            label="Identifiant"
            rules={[
              { required: true, message: 'Choisis un identifiant' },
              { min: 3, message: "L'identifiant doit contenir au moins 3 caractères" },
            ]}
          >
            <Input prefix={<UserOutlined />} autoComplete="username" />
          </Form.Item>

          <Form.Item
            name="userBranch"
            label="Département"
            rules={[{ required: true, message: 'Choisis ton département' }]}
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
            rules={[
              { required: true, message: 'Choisis un mot de passe' },
              { min: 8, message: 'Le mot de passe doit contenir au moins 8 caractères' },
            ]}
          >
            <Input.Password prefix={<LockOutlined />} autoComplete="new-password" />
          </Form.Item>

          <Form.Item
            name="confirmation"
            label="Confirmer le mot de passe"
            dependencies={['userPassword']}
            rules={[
              { required: true, message: 'Confirme ton mot de passe' },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue('userPassword') === value) return Promise.resolve();
                  return Promise.reject(new Error('Les mots de passe ne correspondent pas'));
                },
              }),
            ]}
          >
            <Input.Password prefix={<LockOutlined />} autoComplete="new-password" />
          </Form.Item>

          <Button type="primary" htmlType="submit" block>
            S'inscrire
          </Button>
        </Form>

        <Typography.Paragraph style={{ marginTop: 16, marginBottom: 0, textAlign: 'center' }}>
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </Typography.Paragraph>
      </Card>
    </div>
  );
};

export default Signup;
FILE_EOF

echo "Creation de src/pages/AccueilAdmin.jsx..."
cat > src/pages/AccueilAdmin.jsx << 'FILE_EOF'
import { useNavigate } from 'react-router-dom';
import { Alert, Card, Col, Row, Statistic, Typography } from 'antd';
import { ApartmentOutlined, CalendarOutlined, TeamOutlined, UserOutlined } from '@ant-design/icons';
import useFetch from '../hooks/useFetch';
import { departementApi, employeApi, pointageApi, userApi } from '../api';

const AccueilAdmin = () => {
  const navigate = useNavigate();
  const employes = useFetch(employeApi.getAll);
  const departements = useFetch(departementApi.getAll);
  const pointages = useFetch(pointageApi.getAll);
  const users = useFetch(userApi.getAll);

  const cartes = [
    { titre: 'Employés', icone: <TeamOutlined />, ressource: employes, chemin: '/employes' },
    { titre: 'Départements', icone: <ApartmentOutlined />, ressource: departements, chemin: '/departements' },
    { titre: 'Pointages enregistrés', icone: <CalendarOutlined />, ressource: pointages, chemin: '/pointages' },
    { titre: 'Utilisateurs', icone: <UserOutlined />, ressource: users, chemin: '/users' },
  ];

  const erreur = cartes.find((c) => c.ressource.error)?.ressource.error;

  return (
    <>
      <Typography.Title level={2}>Tableau de bord administrateur</Typography.Title>
      <Typography.Paragraph type="secondary">
        Vue d'ensemble de l'application. Clique sur une carte pour accéder à la rubrique.
      </Typography.Paragraph>

      {erreur && (
        <Alert
          type="error"
          showIcon
          message="Impossible de charger certaines données"
          description={erreur}
          style={{ marginBottom: 16 }}
        />
      )}

      <Row gutter={[16, 16]}>
        {cartes.map((c) => (
          <Col key={c.chemin} xs={24} sm={12} xl={6}>
            <Card hoverable onClick={() => navigate(c.chemin)}>
              <Statistic
                title={c.titre}
                value={c.ressource.data.length}
                prefix={c.icone}
                loading={c.ressource.loading}
              />
            </Card>
          </Col>
        ))}
      </Row>
    </>
  );
};

export default AccueilAdmin;
FILE_EOF

echo "Creation de src/pages/AccueilUtilisateur.jsx..."
cat > src/pages/AccueilUtilisateur.jsx << 'FILE_EOF'
import { useNavigate } from 'react-router-dom';
import { Button, Card, Typography } from 'antd';
import { CalendarOutlined } from '@ant-design/icons';

const AccueilUtilisateur = () => {
  const navigate = useNavigate();

  return (
    <>
      <Typography.Title level={2}>Mon espace</Typography.Title>
      <Card style={{ maxWidth: 480 }}>
        <Typography.Paragraph>
          Consulte tes pointages dans le calendrier : arrivées et départs du matin et de l'après-midi.
        </Typography.Paragraph>
        <Button type="primary" icon={<CalendarOutlined />} onClick={() => navigate('/pointages')}>
          Voir mes pointages
        </Button>
      </Card>
    </>
  );
};

export default AccueilUtilisateur;
FILE_EOF

echo ""
echo "Interface Ant Design creee avec succes !"
echo "Lance : npm run dev"
