import * as EventoModel from '../models/eventosModel.js';

export const listarEventos = async (req, res) => {
  try {
    const data = await EventoModel.obtenerEventosBD();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const guardarEvento = async (req, res) => {
  try {
    const { id_usuario, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion } = req.body;

    // OJO: la clave de la izquierda debe ser EXACTAMENTE el nombre
    // de la columna en Supabase
    const datosParaBD = {
      user_id: id_usuario,
      nombre_evento,
      fecha_evento,
      hora_evento,
      lugar_evento,
      descripcion
    };

    const nuevo = await EventoModel.crearEventoBD(datosParaBD);
    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const editarEvento = async (req, res) => {
  try {
    const editado = await EventoModel.actualizarEventoBD(req.params.id, req.body);
    res.json(editado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const borrarEvento = async (req, res) => {
  try {
    await EventoModel.eliminarEventoBD(req.params.id);
    res.json({ mensaje: "Evento eliminado correctamente" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};