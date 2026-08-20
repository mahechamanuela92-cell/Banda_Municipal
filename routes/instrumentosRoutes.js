import { Router } from 'express';
import { 
    getInstrumentos, 
    createInstrumentoCompleto 
} from '../controllers/instrumentosControllers.js';

const router = Router();

router.get('/', getInstrumentos);
router.post('/', createInstrumentoCompleto);

export default router;