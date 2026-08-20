import { Router } from 'express';
import { listarMultimedia, subirMultimedia } from '../controllers/multimediaController.js';

const router = Router();

router.get('/', listarMultimedia);
router.post('/', subirMultimedia);

export default router;