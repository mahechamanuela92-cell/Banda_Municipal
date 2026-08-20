import { PartiturasModel } from '../models/partiturasModels.js';

export const createCategoria = async (req, res) => {
    try {
        const { nombre_partitura, voz_partitura } = req.body;

        if (!nombre_partitura || !voz_partitura) {
            return res.status(400).json({ error: 'El nombre y la voz de la partitura son obligatorios' });
        }

        const nuevaCategoria = await PartiturasModel.createCategoria(nombre_partitura, voz_partitura);
        return res.status(201).json(nuevaCategoria);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const createPartitura = async (req, res) => {
    try {
        const { id_listado, id_categoria } = req.body;

        if (!id_listado || !id_categoria) {
            return res.status(400).json({ 
                error: 'El id_listado y el id_categoria son obligatorios' 
            });
        }

        const nuevaPartitura = await PartiturasModel.createPartitura(id_listado, id_categoria);
        return res.status(201).json(nuevaPartitura);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const getPartituras = async (req, res) => {
    try {
        const { categoria } = req.query;
        let partituras;

        if (categoria) {
            partituras = await PartiturasModel.getByCategoria(categoria);
        } else {
            partituras = await PartiturasModel.getAll();
        }

        return res.status(200).json(partituras);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};