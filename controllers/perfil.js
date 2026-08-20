import { PerfilModel } from '../models/perfil.js';

// Obtener mi perfil (usa la info extraída del token JWT)
export const obtenerMiPerfil = async (req, res) => {
    try {
        const user_id = req.usuario.id;
        const perfil = await PerfilModel.getPerfilByUserId(user_id);

        if (!perfil) {
            return res.status(404).json({ error: 'Perfil no encontrado' });
        }

        return res.status(200).json(perfil);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Actualizar foto de perfil
export const actualizarFotoPerfil = async (req, res) => {
    try {
        const user_id = req.usuario.id;
        const { foto_perfil } = req.body;

        if (!foto_perfil) {
            return res.status(400).json({ error: 'La URL de la foto es requerida' });
        }

        const data = await PerfilModel.upsertPerfil(user_id, foto_perfil);
        return res.status(200).json({ mensaje: 'Perfil actualizado con éxito', perfil: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};