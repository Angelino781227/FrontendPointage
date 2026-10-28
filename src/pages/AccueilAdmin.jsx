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
