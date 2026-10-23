import {
    guardarMultimedia,
    obtenerMultimedia,
    filtrarPorEvento,
    filtrarPorTipo,
    eliminarMultimedia
} from '../models/multimediaModel.js';
 
//guardar una url de foto o video
export const crearMultimedia = async (req, res) => {
    try {
        const {user_id, id_evento, titulo, tipo_archivo, url_archivo} = req.body;
 
        //validamos los datos
        if (!user_id || !id_evento || !tipo_archivo || !url_archivo) {
            return res.status(400).json({
                error: 'faltan datos del multimedia'
            });
        }
 
        const {data, error} = await guardarMultimedia(user_id, id_evento, titulo, tipo_archivo, url_archivo);
 
        if (error) {
            return res.status(400).json({error: error.message});
        }
 
        res.status(201).json({mensaje: 'archivo guardado correctamente', multimedia: data});
 
    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};
 
//listar y filtrar multimedia (?id_evento= o ?tipo_archivo=)
export const listarMultimedia = async (req, res) => {
    try {
        const {id_evento, tipo_archivo} = req.query;
        let resultado;
 
        if (id_evento) {
            resultado = await filtrarPorEvento(id_evento);
        } else if (tipo_archivo) {
            resultado = await filtrarPorTipo(tipo_archivo);
        } else {
            resultado = await obtenerMultimedia();
        }
 
        const {data, error} = resultado;
 
        if (error) {
            return res.status(400).json({error: error.message});
        }
 
        res.status(200).json(data);
 
    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};
 
//eliminar un archivo multimedia
export const borrarMultimedia = async (req, res) => {
    try {
        const {id} = req.params;
        const {data, error} = await eliminarMultimedia(id);
 
        if (error) {
            return res.status(400).json({error: error.message});
        }
 
        if (!data || data.length === 0) {
            return res.status(404).json({error: 'archivo no encontrado'});
        }
 
        res.status(200).json({mensaje: 'archivo eliminado correctamente'});
 
    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};
 