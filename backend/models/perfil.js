import { supabase } from '../config/supabase.js';

export const PerfilModel = {
    // Obtener los datos del usuario y su foto, aunque aún no exista una fila de perfil.
    getPerfilByUserId: async (user_id) => {
        const { data: usuario, error: errorUsuario } = await supabase
            .from('usuarios')
            .select('user_id, nombre, email, telefono, rol')
            .eq('user_id', user_id)
            .maybeSingle();

        if (errorUsuario) throw errorUsuario;
        if (!usuario) return null;

        const { data: perfil, error: errorPerfil } = await supabase
            .from('perfil')
            .select('foto_perfil')
            .eq('user_id', user_id)
            .maybeSingle();

        if (errorPerfil) throw errorPerfil;
        return { ...usuario, foto_perfil: perfil?.foto_perfil ?? null };
    },

    actualizarDatosPerfil: async (user_id, campos) => {
        const { data, error } = await supabase
            .from('usuarios')
            .update(campos)
            .eq('user_id', user_id)
            .select('user_id, nombre, email, telefono, rol')
            .single();

        if (error) throw error;
        return data;
    },

    // Crear o actualizar perfil (Upsert)
    upsertPerfil: async (user_id, foto_perfil) => {
        const { data, error } = await supabase
            .from('perfil')
            .upsert({ user_id, foto_perfil }, { onConflict: 'user_id' })
            .select('foto_perfil')
            .single();

        if (error) throw error;
        return data;
    }
};