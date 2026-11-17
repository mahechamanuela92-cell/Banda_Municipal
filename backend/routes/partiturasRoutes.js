import { Router } from 'express';
import { 
    createCategoria, 
    createPartitura, 
    getPartituras 
} from '../controllers/partiturasControllers.js';
import { uploadPartitura } from '../config/cloudinary.js';

const router = Router();

const cargarPartitura = (req, res, next) => {
    uploadPartitura.single('archivo')(req, res, (error) => {
        if (!error) return next();

        const limiteExcedido = error.code === 'LIMIT_FILE_SIZE';
        console.error('Error al subir partitura:', error);
        const tipoNoPermitido = error.code === 'UNSUPPORTED_FILE_TYPE';
        return res.status(limiteExcedido ? 413 : tipoNoPermitido ? 415 : 502).json({
            error: limiteExcedido
                ? 'El archivo supera el límite de 50 MB'
                : tipoNoPermitido
                ? error.message
                : 'No se pudo subir la partitura',
            detalle: error.message,
        });
    });
};

// Rutas para categorías de partituras
router.post('/categorias', cargarPartitura, createCategoria);

// Rutas para partituras
router.post('/', createPartitura);
router.get('/', getPartituras);

export default router;