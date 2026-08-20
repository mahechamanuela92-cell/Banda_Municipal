import {Router} from 'express';
import {
    crearMultimedia,
    listarMultimedia,
    borrarMultimedia
} from '../controllers/multimediaController.js';

const router = Router();

router.post('/', crearMultimedia);
router.get('/', listarMultimedia);       //?id_evento= o ?tipo_archivo= opcional
router.delete('/:id', borrarMultimedia);

export default router;