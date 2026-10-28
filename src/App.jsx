import { Navigate, Route, Routes } from 'react-router-dom';
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
    {/* L'application s'ouvre sur la page de connexion */}
    <Route path="/" element={<Navigate to="/login" replace />} />
    <Route path="/login" element={<Login />} />
    <Route path="/signup" element={<Signup />} />

    {/* Pages de l'application, avec le menu */}
    {/* TODO: protéger ces routes une fois l'authentification en place */}
    <Route element={<Layout />}>
      <Route path="/accueil" element={<Accueil />} />
      <Route path="/employes" element={<Employes />} />
      <Route path="/pointages" element={<Pointages />} />
      <Route path="/departements" element={<Departements />} />
      <Route path="/users" element={<Users />} />
    </Route>

    {/* Toute adresse inconnue renvoie vers la connexion */}
    <Route path="*" element={<Navigate to="/login" replace />} />
  </Routes>
);

export default App;
