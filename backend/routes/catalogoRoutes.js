import { Router } from 'express';
import { listarCategorias, listarCatalogo, crearInstrumento } from '../controllers/catalogoController.js';

const router = Router();

router.get('/categorias', listarCategorias);
router.get('/instrumentos', listarCatalogo);
router.post('/instrumentos', crearInstrumento);

export default router;