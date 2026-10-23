import {
    crearEvento,
    obtenerEventos,
    obtenerEventosPorUsuario,
    obtenerEventoPorId,
    editarEvento,
    eliminarEvento
} from '../models/eventosModel.js';

//guardar evento (fecha de concierto)
export const guardarEvento = async (req, res) => {
    try {
        const {user_id, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion} = req.body;

        //validamos los datos
        if (!user_id || !nombre_evento || !fecha_evento) {
            return res.status(400).json({
                error: 'faltan datos del evento'
            });
        }

        const {data, error} = await crearEvento(user_id, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(201).json({mensaje: 'evento creado correctamente', evento: data});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//listar eventos (todos o por usuario si viene ?user_id=)
export const listarEventos = async (req, res) => {
    try {
        const {user_id} = req.query;

        const {data, error} = user_id
            ? await obtenerEventosPorUsuario(user_id)
            : await obtenerEventos();

        if (error) {
            return res.status(400).json({error: error.message});
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//obtener un evento por id
export const obtenerEvento = async (req, res) => {
    try {
        const {id} = req.params;
        const {data, error} = await obtenerEventoPorId(id);

        if (error || !data) {
            return res.status(404).json({error: 'evento no encontrado'});
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//editar un evento
export const actualizarEvento = async (req, res) => {
    try {
        const {id} = req.params;
        const {nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion} = req.body;

        const {data, error} = await editarEvento(id, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        if (!data || data.length === 0) {
            return res.status(404).json({error: 'evento no encontrado'});
        }

        res.status(200).json({mensaje: 'evento actualizado correctamente', evento: data});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};

//eliminar un evento
export const borrarEvento = async (req, res) => {
    try {
        const {id} = req.params;
        const {data, error} = await eliminarEvento(id);

        if (error) {
            return res.status(400).json({error: error.message});
        }

        if (!data || data.length === 0) {
            return res.status(404).json({error: 'evento no encontrado'});
        }

        res.status(200).json({mensaje: 'evento eliminado correctamente'});

    } catch (error) {
        res.status(500).json({error: 'error en el servidor', detalle: error.message});
    }
};