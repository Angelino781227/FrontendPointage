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
              options={departements.data.map((d) => ({ value: d.departementId, label: d.nomDepartement }))}
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
