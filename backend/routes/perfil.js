import { Router } from 'express';
import { obtenerMiPerfil, actualizarMiPerfil, actualizarFotoPerfil } from '../controllers/perfil.js';
import { verificarToken } from '../middlewares/authMiddlewares.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

// Endpoints protegidos por token JWT
router.get('/me', verificarToken, obtenerMiPerfil);
router.put('/me', verificarToken, actualizarMiPerfil);
router.put('/foto', verificarToken, upload.single('foto'), actualizarFotoPerfil);

export default router;