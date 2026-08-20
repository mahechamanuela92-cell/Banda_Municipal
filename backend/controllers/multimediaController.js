import * as MultimediaModel from '../models/multimediaModel.js';

export const listarMultimedia = async (req, res) => {
  try {
    const { tipo } = req.query;
    const data = await MultimediaModel.obtenerMultimediaBD(tipo);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const subirMultimedia = async (req, res) => {
  try {
    const guardado = await MultimediaModel.guardarMultimediaBD(req.body);
    res.status(201).json(guardado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};