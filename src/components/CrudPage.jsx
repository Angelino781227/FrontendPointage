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
