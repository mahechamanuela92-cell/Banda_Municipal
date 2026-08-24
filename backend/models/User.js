import { supabase } from "../config/supabase.js";

// Crear un nuevo usuario (Registro)
export const crearUser = async (nombre, email, password, rol) => {
  const { data, error } = await supabase
    .from("usuarios")
    .insert([{ nombre, email, password, rol }])
    .select("user_id, nombre, email, password, rol");
  return { data, error };
};

// Obtener usuario por email (Login / Validación)
export const obtenerPorEmail = async (email) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("*")
    .eq("email", email)
    .single();
  return { data, error };
};

// Obtener todos los usuarios (CRUD Admin)
export const ObtenerUsuarios = async () => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("user_id, nombre, email, rol, fecha_registro");
  return { data, error };
};

// Obtener usuario por ID (CRUD Admin)
export const obtenerUsuarioPorId = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("user_id, nombre, email, password, rol, fecha_registro")
    .eq("user_id", id)
    .single();
  return { data, error };
};

// Actualizar usuario (CRUD Admin)
export const actualizarUsuario = async (id, campos) => {
  const { data, error } = await supabase
    .from("usuarios")
    .update(campos)
    .eq("user_id", id)
    .select("user_id, nombre, email, rol");
  return { data, error };
};

// Eliminar usuario (CRUD Admin)
export const eliminarUsuario = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .delete()
    .eq("user_id", id)
    .select("user_id, nombre, email, rol");
  return { data, error };
};