import { supabase } from "../config/supabase.js";

// Crear un nuevo usuario (Registro)
export const crearUser = async (nombre, email, password, rol, codigoVerificacion, codigoVerificacionExpiracion, tipo_documento, numero_documento, telefono, acepta_terminos) => {
  const { data, error } = await supabase
    .from("usuarios")
    .insert([
      { 
        nombre, 
        email, 
        password, 
        rol, 
        codigoVerificacion, 
        codigoverificacionExpiracion: codigoVerificacionExpiracion,
        tipo_documento,
        numero_documento,
        telefono,
        acepta_terminos // <-- Nuevo campo agregado
      }
    ])
    .select("user_id, nombre, email, rol, isVerified, codigoVerificacion, codigoverificacionExpiracion, acepta_terminos");
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

// Obtener todos los usuarios con su foto desde la tabla perfil
export const ObtenerUsuarios = async () => {
  const { data: usuarios, error } = await supabase
    .from("usuarios")
    .select("user_id, nombre, email, rol, fecha_registro")
    .order("nombre", { ascending: true });

  if (error || !usuarios) {
    return { data: null, error };
  }

  const { data: perfiles, error: errorPerfiles } = await supabase
    .from("perfil")
    .select("user_id, foto_perfil");

  if (errorPerfiles) {
    console.error("Error obteniendo fotos de perfil:", errorPerfiles);
  }

  const mapaFotos = new Map(
    (perfiles || []).map((p) => [String(p.user_id), p.foto_perfil])
  );

  const usuariosConFoto = usuarios.map((u) => ({
    ...u,
    foto_perfil: mapaFotos.get(String(u.user_id)) ?? null,
  }));

  return { data: usuariosConFoto, error: null };
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
  await supabase.from("perfil").delete().eq("user_id", id);

  const { data, error } = await supabase
    .from("usuarios")
    .delete()
    .eq("user_id", id)
    .select("user_id, nombre, email, rol");
  return { data, error };
};