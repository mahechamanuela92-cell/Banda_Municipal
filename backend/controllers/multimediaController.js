import {
    guardarMultimedia,
    obtenerMultimedia,
    filtrarPorEvento,
    filtrarPorTipo,
    eliminarMultimedia
} from '../models/multimediaModel.js';
import { cloudinary } from '../config/cloudinary.js';
 
//guardar una url de foto o video
export const crearMultimedia = async (req, res) => {
    try {
        const body = req.body ?? {};
        const {id_evento, titulo, tipo_archivo} = body;
        const user_id = req.usuario?.id;
        const url_archivo = req.file?.path ?? body.url_archivo;

        if (!user_id) {
            return res.status(401).json({error: 'Sesión no autenticada'});
        }
 
        //validamos los datos
        if (!['foto', 'video'].includes(tipo_archivo) || !url_archivo) {
            return res.status(400).json({
                error: 'Se requiere un archivo de foto o video válido'
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

        const archivo = data[0];
        const segmentos = archivo.url_archivo?.split('/upload/')[1]?.split('/') ?? [];
        if (segmentos.length > 0) {
            if (/^v\d+$/.test(segmentos[0])) segmentos.shift();
            const nombre = segmentos.pop()?.replace(/\.[^.]+$/, '');
            if (nombre) {
                const publicId = [...segmentos, nombre].join('/');
                await cloudinary.uploader.destroy(publicId, {
                    resource_type: archivo.tipo_archivo === 'video' ? 'video' : 'image',
                });
            }
        }
 
        res.status(200).json({mensaje: 'archivo eliminado correctamente'});
 
    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};
 