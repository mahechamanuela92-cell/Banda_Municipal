import { Router } from 'express';
import { 
    createCategoria, 
    createPartitura, 
    getPartituras 
} from '../controllers/partiturasControllers.js';

const router = Router();

// Rutas para categorías de partituras
router.post('/categorias', createCategoria);

// Rutas para partituras
router.post('/', createPartitura);
router.get('/', getPartituras);

export default router;