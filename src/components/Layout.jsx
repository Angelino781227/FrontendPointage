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
