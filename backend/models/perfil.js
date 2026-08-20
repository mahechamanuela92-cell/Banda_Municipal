import { supabase } from '../config/supabase.js';

export const PerfilModel = {
    // Obtener perfil por user_id trayendo también datos del usuario
    getPerfilByUserId: async (user_id) => {
        const { data, error } = await supabase
            .from('perfil')
            .select('*, usuarios(nombre, email, rol)')
            .eq('user_id', user_id)
            .single();

        if (error) return null;
        return data;
    },

    // Crear o actualizar perfil (Upsert)
    upsertPerfil: async (user_id, foto_perfil) => {
        const { data, error } = await supabase
            .from('perfil')
            .upsert({ user_id, foto_perfil }, { onConflict: 'user_id' })
            .select();

        if (error) throw error;
        return data;
    }
};