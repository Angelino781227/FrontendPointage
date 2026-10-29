import { useMemo } from 'react';
import { Divider, Form, Input, InputNumber, Select } from 'antd';
import CrudPage from '../components/CrudPage';
import useFetch from '../hooks/useFetch';
import { departementApi, employeApi } from '../api';

const VALEURS_PAR_DEFAUT = { nombreEmploye: 0 };

const libelleEmploye = (e) => `${e.matricule} — ${e.nom} ${e.prenoms ?? ''}`.trim();

const Departements = () => {
  const departements = useFetch(departementApi.getAll);
  const employes = useFetch(employeApi.getAll);

  const employeParId = useMemo(
    () => Object.fromEntries(employes.data.map((e) => [e.id, e])),
    [employes.data]
  );

  // Créer un département crée aussi un employé : on recharge donc les deux listes
  const recharger = () => {
    departements.reload();
    employes.reload();
  };

  const columns = [
    {
      title: 'Département',
      dataIndex: 'nomDepartement',
      sorter: (a, b) => a.nomDepartement.localeCompare(b.nomDepartement),
    },
    {
      title: 'Chef',
      key: 'chef',
      render: (_, d) => {
        const chef = employeParId[d.chefDepartementId];
        return chef ? libelleEmploye(chef) : d.chefDepartement;
      },
    },
    {
      title: "Nombre d'employés",
      dataIndex: 'nombreEmploye',
      align: 'right',
      sorter: (a, b) => a.nombreEmploye - b.nombreEmploye,
    },
  ];

  // Corps envoyé au backend :
  //  - création : le backend crée l'employé chef à partir de `nom` et `matricule`
  //  - modification : on envoie l'id de l'employé choisi comme chef
  const toPayload = (values, estEdition) => {
    const commun = { nomDepartement: values.nomDepartement, nombreEmploye: values.nombreEmploye };

    if (!estEdition) {
      return { ...commun, chefDepartement: values.nom, nom: values.nom, matricule: values.matricule };
    }

    const chef = employeParId[values.chefDepartementId];
    return {
      ...commun,
      chefDepartementId: values.chefDepartementId ?? null,
      ...(chef && { chefDepartement: chef.nom }),
    };
  };

  const champsCommuns = (
    <>
      <Form.Item
        name="nomDepartement"
        label="Nom du département"
        rules={[{ required: true, message: 'Le nom du département est obligatoire' }]}
      >
        <Input />
      </Form.Item>
      <Form.Item
        name="nombreEmploye"
        label="Nombre d'employés"
        rules={[{ required: true, message: "Indique le nombre d'employés" }]}
      >
        <InputNumber min={0} style={{ width: '100%' }} />
      </Form.Item>
    </>
  );

  return (
    <CrudPage
      title="Départements"
      nouveau="Nouveau département"
      modifier="Modifier le département"
      supprimer="Supprimer ce département ? (impossible s'il contient encore des employés)"
      api={departementApi}
      idKey="departementId"
      columns={columns}
      rows={departements.data}
      loading={departements.loading}
      error={departements.error}
      reload={recharger}
      valeursParDefaut={VALEURS_PAR_DEFAUT}
      toPayload={toPayload}
    >
      {(estEdition, record) =>
        estEdition ? (
          <>
            {champsCommuns}
            <Form.Item
              name="chefDepartementId"
              label="Chef de département"
              extra="Choisis le chef parmi les employés de ce département"
            >
              <Select
                allowClear
                showSearch
                optionFilterProp="label"
                placeholder="Choisir un employé"
                loading={employes.loading}
                notFoundContent="Aucun employé dans ce département"
                options={employes.data
                  .filter((e) => e.departementId === record.departementId)
                  .map((e) => ({ value: e.id, label: libelleEmploye(e) }))}
              />
            </Form.Item>
          </>
        ) : (
          <>
            {champsCommuns}
            <Divider orientation="left" plain>
              Chef de département (employé créé automatiquement)
            </Divider>
            <Form.Item
              name="nom"
              label="Nom du chef"
              rules={[{ required: true, message: 'Le nom du chef est obligatoire' }]}
            >
              <Input />
            </Form.Item>
            <Form.Item
              name="matricule"
              label="Matricule du chef"
              rules={[{ required: true, message: 'Le matricule du chef est obligatoire' }]}
            >
              <Input />
            </Form.Item>
          </>
        )
      }
    </CrudPage>
  );
};

export default Departements;
