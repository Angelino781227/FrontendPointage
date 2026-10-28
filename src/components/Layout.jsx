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
