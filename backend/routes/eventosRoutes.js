import {Router} from 'express';
import {
    guardarEvento,
    listarEventos,
    obtenerEvento,
    actualizarEvento,
    borrarEvento
} from '../controllers/eventosController.js';
import { verificarToken, verificarAdmin } from '../middlewares/authMiddlewares.js';

const router = Router();

router.post('/', verificarToken, verificarAdmin, guardarEvento);
router.get('/', listarEventos);          //?user_id= opcional
router.get('/:id', obtenerEvento);
router.put('/:id', verificarToken, verificarAdmin, actualizarEvento);
router.delete('/:id', verificarToken, verificarAdmin, borrarEvento);

export default router;