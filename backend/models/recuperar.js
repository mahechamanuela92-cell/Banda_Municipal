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

  saveResetCode: async (user_id, code, expires) => {
    const { data, error } = await supabase
      .from('usuarios')
      .update({ 
        reset_code: code, 
        reset_expires: expires 
      })
      .eq('user_id', user_id); // Cambiado a user_id

    if (error) throw error;
    return data;
  },

  updatePassword: async (user_id, newPassword) => {
    const { data, error } = await supabase
      .from('usuarios')
      .update({ 
        password: newPassword, 
        reset_code: null, 
        reset_expires: null 
      })
      .eq('user_id', user_id); // Cambiado a user_id

    if (error) throw error;
    return data;
  }
};