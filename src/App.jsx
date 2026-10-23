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
