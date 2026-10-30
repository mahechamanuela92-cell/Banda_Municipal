import {Router} from 'express';
import {
    crearMultimedia,
    listarMultimedia,
    borrarMultimedia
} from '../controllers/multimediaController.js';
import { verificarToken, verificarAdmin } from '../middlewares/authMiddlewares.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

const detalleErrorCarga = (error) => {
    const posiblesDetalles = [
        error?.error?.message,
        error?.cause?.message,
        error?.message,
        typeof error === 'string' ? error : null,
    ];
    const detalle = posiblesDetalles.find(
        (valor) => typeof valor === 'string' && valor.trim().length > 0,
    );
    return detalle ?? 'Cloudinary no proporcionó detalles del error';
};

const responderErrorCarga = (error, req, res, next) => {
    if (res.headersSent) return next(error);

    const detalle = detalleErrorCarga(error);
    console.error('Error al subir multimedia:', {
        name: error?.name,
        code: error?.code,
        http_code: error?.http_code ?? error?.error?.http_code,
        message: detalle,
    });
    const limiteExcedido = error.code === 'LIMIT_FILE_SIZE';
    return res.status(limiteExcedido ? 413 : 502).json({
        error: limiteExcedido
            ? 'El archivo supera el límite de 50 MB'
            : 'No se pudo subir el archivo a Cloudinary',
        detalle,
    });
};

const cargarArchivo = (req, res, next) => {
    upload.single('archivo')(req, res, (error) => {
        if (error) return responderErrorCarga(error, req, res, next);
        next();
    });
};

router.post(
    '/',
    verificarToken,
    verificarAdmin,
    cargarArchivo,
    crearMultimedia,
);
router.get('/', listarMultimedia);       //?id_evento= o ?tipo_archivo= opcional
router.delete('/:id', verificarToken, verificarAdmin, borrarMultimedia);

export default router;