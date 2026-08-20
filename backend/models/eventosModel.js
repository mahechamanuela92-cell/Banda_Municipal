import { supabase } from '../config/supabase.js';

export const obtenerEventosBD = async () => {
  const { data, error } = await supabase
    .from('eventos')
    .select('*, usuarios(nombre, correo_electronico)');
  if (error) throw error;
  return data;
};

export const crearEventoBD = async (datos) => {
  const { data, error } = await supabase
    .from('eventos')
    .insert([datos])
    .select();
  if (error) throw error;
  return data;
};

export const actualizarEventoBD = async (id, datos) => {
  const { data, error } = await supabase
    .from('eventos')
    .update(datos)
    .eq('id_evento', id)
    .select();
  if (error) throw error;
  return data;
};

export const eliminarEventoBD = async (id) => {
  const { data, error } = await supabase
    .from('eventos')
    .delete()
    .eq('id_evento', id);
  if (error) throw error;
  return data;
};