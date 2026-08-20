import { Router } from 'express';
import { obtenerMiPerfil, actualizarFotoPerfil } from '../controllers/perfil.js';
import { verificarToken } from '../middlewares/authMiddlewares.js';

const router = Router();

// Endpoints protegidos por token JWT
router.get('/me', verificarToken, obtenerMiPerfil);
router.put('/foto', verificarToken, actualizarFotoPerfil);

export default router;