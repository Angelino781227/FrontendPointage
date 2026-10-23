#!/bin/bash
# Script de structuration du frontend React (pointage-frontend)
# A executer depuis la racine du projet React (a cote de package.json)
# Utilisation : bash setup-frontend.sh
# Hypotheses : projet Vite + JavaScript (pas TypeScript), backend sur http://localhost:5000

if [ ! -f package.json ] || [ ! -d src ]; then
  echo "Erreur : lance ce script depuis la racine du projet React (package.json et src/ introuvables)."
  exit 1
fi

echo "Creation des dossiers..."
mkdir -p src/api src/components src/pages src/hooks src/utils src/styles

echo "Installation des dependances (axios, react-router-dom)..."
npm install axios react-router-dom

echo "Creation de src/api/client.js..."
cat > src/api/client.js << 'FILE_EOF'
import axios from 'axios';

const client = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
  headers: { 'Content-Type': 'application/json' },
});

// Remonte le message d'erreur renvoyé par le backend (errorHandler)
client.interceptors.response.use(
  (response) => response,
  (error) => {
    const message = error.response?.data?.message || error.message || 'Erreur réseau';
    return Promise.reject(new Error(message));
  }
);

export default client;
FILE_EOF

echo "Creation de src/api/crud.js..."
cat > src/api/crud.js << 'FILE_EOF'
import client from './client';

// Fabrique les 5 opérations CRUD d'une ressource du backend
export const createCrudApi = (resource) => ({
  getAll: (params) => client.get(`/${resource}`, { params }).then((res) => res.data),
  getById: (id) => client.get(`/${resource}/${id}`).then((res) => res.data),
  create: (data) => client.post(`/${resource}`, data).then((res) => res.data),
  update: (id, data) => client.put(`/${resource}/${id}`, data).then((res) => res.data),
  remove: (id) => client.delete(`/${resource}/${id}`).then((res) => res.data),
});
FILE_EOF

echo "Creation de src/api/index.js..."
cat > src/api/index.js << 'FILE_EOF'
import { createCrudApi } from './crud';

export const departementApi = createCrudApi('departements');
export const employeApi = createCrudApi('employes');
export const pointageApi = createCrudApi('pointages'); // getAll({ employe, date })
export const userApi = createCrudApi('users');
FILE_EOF

echo "Creation de src/hooks/useFetch.js..."
cat > src/hooks/useFetch.js << 'FILE_EOF'
import { useCallback, useEffect, useState } from 'react';

// Charge une liste depuis l'API avec états de chargement et d'erreur
const useFetch = (fetchFn) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await fetchFn());
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [fetchFn]);

  useEffect(() => {
    load();
  }, [load]);

  return { data, loading, error, reload: load };
};

export default useFetch;
FILE_EOF

echo "Creation de src/utils/format.js..."
cat > src/utils/format.js << 'FILE_EOF'
export const coche = (valeur) => (valeur ? '✓' : '✗');

export const libelleRole = (estAdmin) => (estAdmin ? 'Administrateur' : 'Utilisateur');
FILE_EOF

echo "Creation de src/components/DataTable.jsx..."
cat > src/components/DataTable.jsx << 'FILE_EOF'
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
FILE_EOF

echo "Creation de src/components/Layout.jsx..."
cat > src/components/Layout.jsx << 'FILE_EOF'
import { NavLink, Outlet } from 'react-router-dom';

const liens = [
  { to: '/', label: 'Accueil' },
  { to: '/employes', label: 'Employés' },
  { to: '/pointages', label: 'Pointages' },
  { to: '/departements', label: 'Départements' },
  { to: '/users', label: 'Utilisateurs' },
];

const Layout = () => (
  <>
    <nav className="navbar">
      {liens.map((lien) => (
        <NavLink key={lien.to} to={lien.to} end={lien.to === '/'}>
          {lien.label}
        </NavLink>
      ))}
    </nav>
    <main className="contenu">
      <Outlet />
    </main>
  </>
);

export default Layout;
FILE_EOF

echo "Creation de src/pages/Accueil.jsx..."
cat > src/pages/Accueil.jsx << 'FILE_EOF'
const Accueil = () => (
  <>
    <h1>Gestion de pointage</h1>
    <p>Choisis une rubrique dans le menu pour commencer.</p>
  </>
);

export default Accueil;
FILE_EOF

echo "Creation de src/pages/Employes.jsx..."
cat > src/pages/Employes.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { employeApi } from '../api';

const columns = [
  { header: 'Matricule', accessor: 'matricule' },
  { header: 'CIN', accessor: 'cin' },
  { header: 'Nom', accessor: 'nom' },
  { header: 'Prénoms', accessor: 'prenoms' },
  { header: 'Département', accessor: 'departement' },
  { header: 'Fonction', accessor: 'fonction' },
  { header: 'Téléphone', accessor: 'telephone' },
  { header: 'Adresse', accessor: 'adresse' },
];

const Employes = () => {
  const { data, loading, error } = useFetch(employeApi.getAll);

  return (
    <>
      <h1>Employés</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Employes;
FILE_EOF

echo "Creation de src/pages/Departements.jsx..."
cat > src/pages/Departements.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { departementApi } from '../api';

const columns = [
  { header: 'Département', accessor: 'nomDepartement' },
  { header: 'Chef', accessor: 'chefDepartement' },
  { header: "Nombre d'employés", accessor: 'nombreEmploye' },
];

const Departements = () => {
  const { data, loading, error } = useFetch(departementApi.getAll);

  return (
    <>
      <h1>Départements</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Departements;
FILE_EOF

echo "Creation de src/pages/Pointages.jsx..."
cat > src/pages/Pointages.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { pointageApi } from '../api';
import { coche } from '../utils/format';

// Le backend renvoie l'employé lié sous la clé "Employe"
const columns = [
  { header: 'Matricule', render: (p) => p.Employe?.matricule },
  { header: 'Employé', render: (p) => (p.Employe ? `${p.Employe.nom} ${p.Employe.prenoms}` : '') },
  { header: 'Date', accessor: 'date' },
  { header: 'Arrivée matin', render: (p) => coche(p.arriveeMatin) },
  { header: 'Départ matin', render: (p) => coche(p.departMatin) },
  { header: 'Arrivée après-midi', render: (p) => coche(p.arriveeApresMidi) },
  { header: 'Départ après-midi', render: (p) => coche(p.departApresMidi) },
];

const Pointages = () => {
  const { data, loading, error } = useFetch(pointageApi.getAll);

  return (
    <>
      <h1>Pointages</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Pointages;
FILE_EOF

echo "Creation de src/pages/Users.jsx..."
cat > src/pages/Users.jsx << 'FILE_EOF'
import DataTable from '../components/DataTable';
import useFetch from '../hooks/useFetch';
import { userApi } from '../api';
import { libelleRole } from '../utils/format';

const columns = [
  { header: 'Identifiant', accessor: 'userLogin' },
  { header: 'Rôle', render: (u) => libelleRole(u.userRole) },
  { header: 'Département (id)', accessor: 'userBranch' },
];

const Users = () => {
  const { data, loading, error } = useFetch(userApi.getAll);

  return (
    <>
      <h1>Utilisateurs</h1>
      <DataTable columns={columns} rows={data} loading={loading} error={error} />
    </>
  );
};

export default Users;
FILE_EOF

echo "Creation de src/App.jsx..."
cat > src/App.jsx << 'FILE_EOF'
import { Route, Routes } from 'react-router-dom';
import Layout from './components/Layout';
import Accueil from './pages/Accueil';
import Departements from './pages/Departements';
import Employes from './pages/Employes';
import Pointages from './pages/Pointages';
import Users from './pages/Users';

const App = () => (
  <Routes>
    <Route element={<Layout />}>
      <Route path="/" element={<Accueil />} />
      <Route path="/employes" element={<Employes />} />
      <Route path="/pointages" element={<Pointages />} />
      <Route path="/departements" element={<Departements />} />
      <Route path="/users" element={<Users />} />
    </Route>
  </Routes>
);

export default App;
FILE_EOF

echo "Creation de src/main.jsx..."
cat > src/main.jsx << 'FILE_EOF'
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import './styles/global.css';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </StrictMode>
);
FILE_EOF

echo "Creation de src/styles/global.css..."
cat > src/styles/global.css << 'FILE_EOF'
body {
  margin: 0;
  font-family: system-ui, sans-serif;
  background: #f5f6f8;
  color: #1f2933;
}

.navbar {
  display: flex;
  gap: 1rem;
  padding: 0.75rem 1.5rem;
  background: #1f2933;
}

.navbar a {
  color: #cbd2d9;
  text-decoration: none;
}

.navbar a.active {
  color: #fff;
  font-weight: 600;
}

.contenu {
  padding: 1.5rem;
}

.table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
}

.table th,
.table td {
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #e4e7eb;
  text-align: left;
}

.erreur {
  color: #c0392b;
}
FILE_EOF

# Variables d'environnement : .env.example toujours, .env seulement s'il n'existe pas
echo "Creation de .env.example..."
cat > .env.example << 'FILE_EOF'
VITE_API_URL=http://localhost:5000/api
FILE_EOF

if [ ! -f .env ]; then
  echo "Creation de .env..."
  cp .env.example .env
else
  echo ".env existe deja, conserve tel quel."
fi

# S'assurer que .env n'est jamais commite
if [ -f .gitignore ]; then
  if ! grep -qx '.env' .gitignore; then
    printf '\n.env\n' >> .gitignore
    echo ".env ajoute au .gitignore."
  fi
else
  printf '.env\nnode_modules\n' > .gitignore
  echo ".gitignore cree."
fi

echo ""
echo "Frontend structure avec succes !"
echo "Etapes suivantes :"
echo "  1. Lance le backend (npm run dev dans pointage-backend, port 5000)"
echo "  2. Lance le frontend : npm run dev"