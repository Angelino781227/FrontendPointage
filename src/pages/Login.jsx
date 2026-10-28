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
