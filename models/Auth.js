import { supabase } from '../config/supabase.js';

export const AuthModel = {
    // Buscar usuario por correo para el Login
    findByEmail: async (email) => {
        const { data, error } = await supabase
            .from('usuarios')
            .select('*')
            .eq('email', email)
            .maybeSingle();

        if (error) throw error;
        return data;
    },

    // Registrar un nuevo usuario
    createUser: async (nombre, email, password, rol) => {
        const { data, error } = await supabase
            .from('usuarios')
            .insert([{ 
                nombre, 
                email, 
                password, // <--- Cambiado de 'contrasena' a 'password'
                rol 
            }])
            .select('user_id, nombre, email, rol, fecha_registro')
            .single();

        if (error) throw error;
        return data;
    }
};