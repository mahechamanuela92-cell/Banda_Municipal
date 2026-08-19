import { supabase } from '../config/supabase.js';

export const AuthModel = {
    findByEmail: async (correo) => {
        const { data, error } = await supabase
            .from('usuarios')
            .select('*')
            .eq('correo', correo)
            .maybeSingle();

        if (error) throw error;
        return data;
    },

    createUser: async (nombre, correo, contrasena, rol) => {
        const { data, error } = await supabase
            .from('usuarios')
            .insert([{ nombre, correo, contrasena, rol }])
            .select('user_id, nombre, correo, rol, fecha_registro')
            .single();

        if (error) throw error;
        return data;
    }
};