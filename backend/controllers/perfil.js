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

// Actualizar únicamente los datos del usuario autenticado.
export const actualizarMiPerfil = async (req, res) => {
    try {
        const campos = {};
        for (const campo of ['nombre', 'email', 'telefono']) {
            if (req.body[campo] !== undefined) {
                campos[campo] = typeof req.body[campo] === 'string'
                    ? req.body[campo].trim()
                    : req.body[campo];
            }
        }

        if (Object.keys(campos).length === 0) {
            return res.status(400).json({ error: 'No hay datos para actualizar' });
        }
        if ((campos.nombre !== undefined && !campos.nombre) ||
            (campos.email !== undefined && !campos.email)) {
            return res.status(400).json({ error: 'El nombre y el correo no pueden estar vacíos' });
        }

        const perfil = await PerfilModel.actualizarDatosPerfil(req.usuario.id, campos);
        return res.status(200).json({ mensaje: 'Perfil actualizado con éxito', perfil });
    } catch (error) {
        if (error.code === '23505') {
            return res.status(409).json({ error: 'Este correo ya está registrado' });
        }
        return res.status(500).json({ error: error.message });
    }
};

// Actualizar foto de perfil
export const actualizarFotoPerfil = async (req, res) => {
    try {
        const user_id = req.usuario.id;
        const foto_perfil = req.file?.path ?? req.body.foto_perfil;

        if (!foto_perfil) {
            return res.status(400).json({ error: 'La URL de la foto es requerida' });
        }

        const data = await PerfilModel.upsertPerfil(user_id, foto_perfil);
        return res.status(200).json({ mensaje: 'Perfil actualizado con éxito', perfil: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};