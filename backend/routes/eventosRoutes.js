import { Router } from 'express';
import { listarEventos, guardarEvento, editarEvento, borrarEvento } from '../controllers/eventosController.js';

const router = Router();

router.get('/', listarEventos);
router.post('/', guardarEvento);
router.put('/:id', editarEvento);
router.delete('/:id', borrarEvento);

export default router;