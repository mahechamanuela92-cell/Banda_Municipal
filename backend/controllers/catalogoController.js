import {
    obtenerCategorias,
    crearCategoria,
    obtenerCatalogo,
    obtenerCatalogoPorCategoria,
    guardarInstrumentoCatalogo,
    eliminarInstrumentoCatalogo
} from '../models/catalogoModel.js';

//listar categorias de instrumentos
export const listarCategorias = async (req, res) => {
    try {
        const {data, error} = await obtenerCategorias();

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//crear una nueva categoria
export const crearNuevaCategoria = async (req, res) => {
    try {
        const {nombre_categoria} = req.body;

        if (!nombre_categoria) {
            return res.status(400).json({error: 'falta el nombre de la categoria'});
        }

        const {data, error} = await crearCategoria(nombre_categoria);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(201).json({mensaje: 'categoria creada correctamente', categoria: data});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//listar el catalogo completo o filtrado por categoria (?id_categoria=)
export const listarCatalogo = async (req, res) => {
    try {
        const {id_categoria} = req.query;

        const {data, error} = id_categoria
            ? await obtenerCatalogoPorCategoria(id_categoria)
            : await obtenerCatalogo();

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//guardar un instrumento en el catalogo con url de imagen y audio
export const crearInstrumentoCatalogo = async (req, res) => {
    try {
        const {id_categoria, nombre_instrumento, descripcion, url_imagen, url_audio} = req.body;

        //validamos los datos
        if (!id_categoria || !nombre_instrumento) {
            return res.status(400).json({
                error: 'faltan datos del instrumento'
            });
        }

        const {data, error} = await guardarInstrumentoCatalogo(id_categoria, nombre_instrumento, descripcion, url_imagen, url_audio);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(201).json({mensaje: 'instrumento guardado correctamente', instrumento: data});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//eliminar un instrumento del catalogo
export const borrarInstrumentoCatalogo = async (req, res) => {
    try {
        const {id} = req.params;
        const {data, error} = await eliminarInstrumentoCatalogo(id);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        if (!data || data.length === 0) {
            return res.status(404).json({error: 'instrumento no encontrado'});
        }

        res.status(200).json({mensaje: 'instrumento eliminado correctamente'});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};