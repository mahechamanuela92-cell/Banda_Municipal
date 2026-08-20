import {Router} from 'express';
import {
    guardarEvento,
    listarEventos,
    obtenerEvento,
    actualizarEvento,
    borrarEvento
} from '../controllers/eventosController.js';

const router = Router();

router.post('/', guardarEvento);
router.get('/', listarEventos);          //?user_id= opcional
router.get('/:id', obtenerEvento);
router.put('/:id', actualizarEvento);
router.delete('/:id', borrarEvento);

export default router;