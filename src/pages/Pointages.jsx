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
