import { PartiturasModel } from '../models/partiturasModels.js';
// Si subes a Cloudinary, importarías tu configuración o servicio aquí
// import cloudinary from '../config/cloudinary.js'; 

export const createCategoria = async (req, res) => {
    try {
        const body = req.body ?? {};
        const nombre_partitura = typeof body.nombre_partitura === 'string'
            ? body.nombre_partitura.trim()
            : '';
        const voz_partitura = typeof body.voz_partitura === 'string'
            ? body.voz_partitura.trim()
            : '';
        const archivo = req.file;

        if (!nombre_partitura || !voz_partitura || !archivo) {
            return res.status(400).json({
                error: 'El nombre, la voz y el archivo de la partitura son obligatorios'
            });
        }

        const archivoUrl = archivo.path || archivo.filename || '';

        const nuevaCategoria = await PartiturasModel.createCategoria(
            nombre_partitura,
            voz_partitura,
            archivoUrl
        );
        return res.status(201).json(nuevaCategoria);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const createPartitura = async (req, res) => {
    try {
        const body = req.body ?? {};
        const id_listado = body.id_listado;
        const id_categoria = body.id_categoria;
        const archivo = req.file; // 📁 Aquí llega el archivo gracias a Multer

        if (!id_listado || !id_categoria) {
            return res.status(400).json({ 
                error: 'El id_listado y el id_categoria son obligatorios' 
            });
        }

        if (!archivo) {
            return res.status(400).json({ error: 'Debes adjuntar un archivo PDF o una imagen' });
        }

        // 🌟 Aquí subes el archivo a Cloudinary / Supabase Storage y obtienes la URL pública
        // Ejemplo genérico de URL obtenida tras subir el archivo:
        const archivoUrl = archivo.path || archivo.filename || ''; // O la URL que te retorne tu servicio de almacenamiento

        // Guardas en la base de datos incluyendo la URL del archivo
        const nuevaPartitura = await PartiturasModel.createPartitura(id_listado, id_categoria, archivoUrl);
        
        return res.status(201).json({
            message: 'Partitura subida con éxito',
            data: nuevaPartitura
        });
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