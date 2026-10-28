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
