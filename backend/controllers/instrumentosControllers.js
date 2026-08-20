import { InstrumentosModel } from '../models/instrumentosModels.js';

export const getInstrumentos = async (req, res) => {
    try {
        const datos = await InstrumentosModel.getAll();
        res.status(200).json(datos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const createInstrumentoCompleto = async (req, res) => {
    try {
        const { numero_serial, nombre_de_instrumento, instrumento_en } = req.body;

        const instrumento = await InstrumentosModel.createInstrumento(numero_serial);
        const detalle = await InstrumentosModel.createDetalle(
            instrumento.id_instrumentos,
            nombre_de_instrumento,
            instrumento_en
        );

        res.status(201).json({ instrumento, detalle });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};