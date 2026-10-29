import { Alert, Table, Typography } from 'antd';

// columns : colonnes Ant Design [{ title, dataIndex, render, sorter }]
// extra : élément affiché à droite du titre (ex. bouton d'ajout)
// rowKey : nom de la clé primaire des lignes ('id' par défaut)
const DataTable = ({ title, extra, columns, rows, loading, error, rowKey = 'id' }) => (
  <>
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 8,
        marginBottom: 16,
      }}
    >
      <Typography.Title level={2} style={{ margin: 0 }}>
        {title}
      </Typography.Title>
      {extra}
    </div>

    {error && (
      <Alert
        type="error"
        showIcon
        message="Erreur de chargement"
        description={error}
        style={{ marginBottom: 16 }}
      />
    )}

    <Table
      rowKey={rowKey}
      columns={columns}
      dataSource={rows}
      loading={loading}
      pagination={{ pageSize: 10, hideOnSinglePage: true }}
      scroll={{ x: 'max-content' }}
    />
  </>
);

export default DataTable;
