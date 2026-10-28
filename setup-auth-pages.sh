#!/bin/bash
# Ajoute les pages Login, Signup et les accueils par role au frontend React
# A executer depuis la racine du projet React (apres setup-frontend.sh)
# Utilisation : bash setup-auth-pages.sh
# Pages uniquement : aucune logique d'authentification pour le moment (TODO dans le code)

if [ ! -f package.json ] || [ ! -d src/pages ]; then
  echo "Erreur : lance ce script depuis la racine du projet React, apres setup-frontend.sh."
  exit 1
fi

echo "Creation de src/pages/Login.jsx..."
cat > src/pages/Login.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Link } from 'react-router-dom';

const Login = () => {
  const [form, setForm] = useState({ userLogin: '', userPassword: '' });

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: appeler l'API de connexion (à implémenter)
  };

  return (
    <div className="auth-page">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h1>Connexion</h1>

        <label htmlFor="userLogin">Identifiant</label>
        <input
          id="userLogin"
          name="userLogin"
          type="text"
          value={form.userLogin}
          onChange={handleChange}
          autoComplete="username"
          required
        />

        <label htmlFor="userPassword">Mot de passe</label>
        <input
          id="userPassword"
          name="userPassword"
          type="password"
          value={form.userPassword}
          onChange={handleChange}
          autoComplete="current-password"
          required
        />

        <button type="submit">Se connecter</button>

        <p>
          Pas encore de compte ? <Link to="/signup">Créer un compte</Link>
        </p>
      </form>
    </div>
  );
};

export default Login;
FILE_EOF

echo "Creation de src/pages/Signup.jsx..."
cat > src/pages/Signup.jsx << 'FILE_EOF'
import { useState } from 'react';
import { Link } from 'react-router-dom';
import useFetch from '../hooks/useFetch';
import { departementApi } from '../api';

// Le rôle (userRole) n'est volontairement pas dans ce formulaire :
// il ne doit jamais être choisi par l'utilisateur lui-même à l'inscription.
const Signup = () => {
  const [form, setForm] = useState({
    userLogin: '',
    userPassword: '',
    confirmation: '',
    userBranch: '',
  });
  const { data: departements, loading, error } = useFetch(departementApi.getAll);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: vérifier que userPassword === confirmation, puis appeler l'API d'inscription (à implémenter)
  };

  return (
    <div className="auth-page">
      <form className="auth-form" onSubmit={handleSubmit}>
        <h1>Créer un compte</h1>

        <label htmlFor="userLogin">Identifiant</label>
        <input
          id="userLogin"
          name="userLogin"
          type="text"
          value={form.userLogin}
          onChange={handleChange}
          autoComplete="username"
          minLength={3}
          required
        />

        <label htmlFor="userBranch">Département</label>
        <select
          id="userBranch"
          name="userBranch"
          value={form.userBranch}
          onChange={handleChange}
          required
        >
          <option value="">
            {loading ? 'Chargement...' : 'Choisir un département'}
          </option>
          {departements.map((dep) => (
            <option key={dep.id} value={dep.id}>
              {dep.nomDepartement}
            </option>
          ))}
        </select>
        {error && <p className="erreur">Départements indisponibles : {error}</p>}

        <label htmlFor="userPassword">Mot de passe</label>
        <input
          id="userPassword"
          name="userPassword"
          type="password"
          value={form.userPassword}
          onChange={handleChange}
          autoComplete="new-password"
          minLength={8}
          required
        />

        <label htmlFor="confirmation">Confirmer le mot de passe</label>
        <input
          id="confirmation"
          name="confirmation"
          type="password"
          value={form.confirmation}
          onChange={handleChange}
          autoComplete="new-password"
          minLength={8}
          required
        />

        <button type="submit">S'inscrire</button>

        <p>
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
      </form>
    </div>
  );
};

export default Signup;
FILE_EOF

echo "Creation de src/pages/AccueilAdmin.jsx..."
cat > src/pages/AccueilAdmin.jsx << 'FILE_EOF'
import { Link } from 'react-router-dom';

const AccueilAdmin = () => (
  <>
    <h1>Tableau de bord administrateur</h1>
    <p>Gère les employés, les départements, les pointages et les comptes utilisateurs.</p>
    <ul>
      <li><Link to="/employes">Gérer les employés</Link></li>
      <li><Link to="/departements">Gérer les départements</Link></li>
      <li><Link to="/pointages">Consulter tous les pointages</Link></li>
      <li><Link to="/users">Gérer les utilisateurs</Link></li>
    </ul>
  </>
);

export default AccueilAdmin;
FILE_EOF

echo "Creation de src/pages/AccueilUtilisateur.jsx..."
cat > src/pages/AccueilUtilisateur.jsx << 'FILE_EOF'
import { Link } from 'react-router-dom';

const AccueilUtilisateur = () => (
  <>
    <h1>Mon espace</h1>
    <p>Consulte tes pointages de la semaine.</p>
    <ul>
      <li><Link to="/pointages">Voir mes pointages</Link></li>
    </ul>
  </>
);

export default AccueilUtilisateur;
FILE_EOF

echo "Creation de src/pages/Accueil.jsx (choix selon le role)..."
cat > src/pages/Accueil.jsx << 'FILE_EOF'
import AccueilAdmin from './AccueilAdmin';
import AccueilUtilisateur from './AccueilUtilisateur';

// TODO: remplacer par l'utilisateur connecté (contexte d'authentification, à venir).
// En attendant, change cette valeur pour tester les deux accueils :
// true = administrateur (userRole), false = utilisateur standard.
const ROLE_ADMIN_TEMPORAIRE = true;

const Accueil = () => (ROLE_ADMIN_TEMPORAIRE ? <AccueilAdmin /> : <AccueilUtilisateur />);

export default Accueil;
FILE_EOF

echo "Mise a jour de src/App.jsx (routes /login et /signup hors du menu)..."
cat > src/App.jsx << 'FILE_EOF'
import { Route, Routes } from 'react-router-dom';
import Layout from './components/Layout';
import Accueil from './pages/Accueil';
import Departements from './pages/Departements';
import Employes from './pages/Employes';
import Login from './pages/Login';
import Pointages from './pages/Pointages';
import Signup from './pages/Signup';
import Users from './pages/Users';

const App = () => (
  <Routes>
    {/* Pages publiques, sans le menu de navigation */}
    <Route path="/login" element={<Login />} />
    <Route path="/signup" element={<Signup />} />

    {/* Pages de l'application, avec le menu */}
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

# Styles des pages d'authentification (ajoutes une seule fois)
if grep -q 'pages-auth' src/styles/global.css 2>/dev/null; then
  echo "Styles d'authentification deja presents, rien a faire."
else
  echo "Ajout des styles d'authentification dans src/styles/global.css..."
  cat >> src/styles/global.css << 'FILE_EOF'

/* pages-auth */
.auth-page {
  display: flex;
  justify-content: center;
  padding: 3rem 1rem;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  width: 100%;
  max-width: 380px;
  padding: 1.5rem;
  background: #fff;
  border: 1px solid #e4e7eb;
  border-radius: 8px;
}

.auth-form input,
.auth-form select {
  padding: 0.5rem;
  border: 1px solid #cbd2d9;
  border-radius: 4px;
}

.auth-form button {
  margin-top: 0.5rem;
  padding: 0.6rem;
  border: none;
  border-radius: 4px;
  background: #1f2933;
  color: #fff;
  cursor: pointer;
}
FILE_EOF
fi

echo ""
echo "Pages d'authentification creees avec succes !"
echo "  /login    -> connexion"
echo "  /signup   -> inscription"
echo "  /         -> accueil admin ou utilisateur (bascule dans src/pages/Accueil.jsx)"
