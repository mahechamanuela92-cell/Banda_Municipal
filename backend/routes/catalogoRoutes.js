import {Router} from 'express';
import {
    listarCategorias,
    crearNuevaCategoria,
    listarCatalogo,
    crearInstrumentoCatalogo,
    borrarInstrumentoCatalogo
} from '../controllers/catalogoController.js';

const router = Router();

//categorias
router.get('/categorias', listarCategorias);
router.post('/categorias', crearNuevaCategoria);

//catalogo de instrumentos
router.get('/', listarCatalogo);              //?id_categoria= opcional
router.post('/', crearInstrumentoCatalogo);
router.delete('/:id', borrarInstrumentoCatalogo);

export default router;