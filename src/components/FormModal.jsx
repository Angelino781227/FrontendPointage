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
