import { supabase } from '../config/supabase.js';

export const RecuperarModel = {
    findUserByEmail: async (email) => {
        const { data, error } = await supabase
            .from('usuarios')
            .select('*')
            .eq('email', email)
            .single();

        if (error) return null;
        return data;
    },

    saveResetCode: async (id, code, expires) => {
        const { data, error } = await supabase
            .from('usuarios')
            .update({ 
                reset_code: code, 
                reset_expires: expires 
            })
            .eq('id', id);

        if (error) throw error;
        return data;
    },

    updatePassword: async (id, newPassword) => {
        const { data, error } = await supabase
            .from('usuarios')
            .update({ 
                password: newPassword, 
                reset_code: null, 
                reset_expires: null 
            })
            .eq('id', id);

        if (error) throw error;
        return data;
    }
};