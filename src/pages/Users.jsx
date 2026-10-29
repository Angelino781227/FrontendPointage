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
