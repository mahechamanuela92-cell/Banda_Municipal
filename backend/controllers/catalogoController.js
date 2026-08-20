import * as CatalogoModel from '../models/catalogoModel.js';

export const listarCategorias = async (req, res) => {
  try {
    const data = await CatalogoModel.obtenerCategoriasBD();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const listarCatalogo = async (req, res) => {
  try {
    const data = await CatalogoModel.obtenerCatalogoBD();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const crearInstrumento = async (req, res) => {
  try {
    const nuevo = await CatalogoModel.guardarInstrumentoBD(req.body);
    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};