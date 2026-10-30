import {Router} from 'express';
import {
    crearMultimedia,
    listarMultimedia,
    borrarMultimedia
} from '../controllers/multimediaController.js';
import { verificarToken, verificarAdmin } from '../middlewares/authMiddlewares.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

const responderErrorCarga = (error, req, res, next) => {
    if (res.headersSent) return next(error);

    console.error('Error al subir multimedia:', error);
    const limiteExcedido = error.code === 'LIMIT_FILE_SIZE';
    return res.status(limiteExcedido ? 413 : 502).json({
        error: limiteExcedido
            ? 'El archivo supera el límite de 50 MB'
            : 'No se pudo subir el archivo a Cloudinary',
        detalle: error.message,
    });
};

router.post(
    '/',
    verificarToken,
    verificarAdmin,
    upload.single('archivo'),
    crearMultimedia,
    responderErrorCarga,
);
router.get('/', listarMultimedia);       //?id_evento= o ?tipo_archivo= opcional
router.delete('/:id', verificarToken, verificarAdmin, borrarMultimedia);

export default router;