import {Router} from 'express';
import {
    crearMultimedia,
    listarMultimedia,
    borrarMultimedia
} from '../controllers/multimediaController.js';
import { verificarToken, verificarAdmin } from '../middlewares/authMiddlewares.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

router.post('/', verificarToken, verificarAdmin, upload.single('archivo'), crearMultimedia);
router.get('/', listarMultimedia);       //?id_evento= o ?tipo_archivo= opcional
router.delete('/:id', verificarToken, verificarAdmin, borrarMultimedia);

export default router;