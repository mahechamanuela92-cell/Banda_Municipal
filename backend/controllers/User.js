import { ObtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario, eliminarUsuario } from "../models/User.js";

export const getUsuarios = async (req, res) => {
  try {
    const { data, error } = await ObtenerUsuarios();
    if (error) {
      console.error("Error de Supabase en ObtenerUsuarios:", error);
      return res.status(500).json({ error: "Error al obtener los usuarios" });
    }
    return res.status(200).json({ usuarios: data });
  } catch (error) {
    console.error("Error en getUsuarios:", error);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

export const getUsuarioPorId = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await obtenerUsuarioPorId(id);
    if (error) {
      console.error("Error de Supabase en obtenerUsuarioPorId:", error);
    }
    if (error || !data) return res.status(404).json({ error: "Usuario no encontrado" });
    return res.status(200).json({ usuario: data });
  } catch (error) {
    console.error("Error en getUsuarioPorId:", error);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

export const updateUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, email, rol } = req.body;
    const { data, error } = await actualizarUsuario(id, { nombre, email, rol });
    if (error) {
      console.error("Error de Supabase en actualizarUsuario:", error);
      return res.status(500).json({ error: "Error al actualizar usuario" });
    }
    return res.status(200).json({ usuario: data });
  } catch (error) {
    console.error("Error en updateUsuario:", error);
    return res.status(500).json({ error: error.message });
  }
};

export const deleteUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await eliminarUsuario(id);
    if (error) {
      console.error("Error de Supabase en eliminarUsuario:", error);
      return res.status(500).json({ error: "Error al eliminar usuario" });
    }
    return res.status(200).json({ usuario: data });
  } catch (error) {
    console.error("Error en deleteUsuario:", error);
    return res.status(500).json({ error: error.message });
  }
};