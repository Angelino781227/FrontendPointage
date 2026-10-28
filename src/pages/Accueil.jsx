import AccueilAdmin from './AccueilAdmin';
import AccueilUtilisateur from './AccueilUtilisateur';

// TODO: remplacer par l'utilisateur connecté (contexte d'authentification, à venir).
// En attendant, change cette valeur pour tester les deux accueils :
// true = administrateur (userRole), false = utilisateur standard.
const ROLE_ADMIN_TEMPORAIRE = true;

const Accueil = () => (ROLE_ADMIN_TEMPORAIRE ? <AccueilAdmin /> : <AccueilUtilisateur />);

export default Accueil;
