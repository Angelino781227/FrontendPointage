// columns : [{ header: 'Nom', accessor: 'nom' }, { header: 'X', render: (ligne) => ... }]
const DataTable = ({ columns, rows, loading, error, emptyMessage = 'Aucune donnée' }) => {
  if (loading) return <p>Chargement...</p>;
  if (error) return <p className="erreur">Erreur : {error}</p>;
  if (rows.length === 0) return <p>{emptyMessage}</p>;

  return (
    <table className="table">
      <thead>
        <tr>
          {columns.map((col) => (
            <th key={col.header}>{col.header}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id}>
            {columns.map((col) => (
              <td key={col.header}>{col.render ? col.render(row) : row[col.accessor]}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default DataTable;
