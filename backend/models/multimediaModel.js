import { supabase } from '../config/supabase.js';

export const obtenerMultimediaBD = async (tipo_archivo) => {
  let consulta = supabase.from('multimedia').select('*, eventos(nombre_evento)');
  if (tipo_archivo) consulta = consulta.eq('tipo_archivo', tipo_archivo);
  
  const { data, error } = await consulta;
  if (error) throw error;
  return data;
};

export const guardarMultimediaBD = async (datos) => {
  const { data, error } = await supabase.from('multimedia').insert([datos]).select();
  if (error) throw error;
  return data;
};