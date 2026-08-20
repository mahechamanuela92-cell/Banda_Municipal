import { supabase } from '../config/supabase.js';

export const obtenerCategoriasBD = async () => {
  const { data, error } = await supabase.from('categorias_instrumentos').select('*');
  if (error) throw error;
  return data;
};

export const obtenerCatalogoBD = async () => {
  const { data, error } = await supabase
    .from('catálogo_instrumentos')
    .select('*, categorias_instrumentos(nombre_categoria)');
  if (error) throw error;
  return data;
};

export const guardarInstrumentoBD = async (datos) => {
  const { data, error } = await supabase.from('catálogo_instrumentos').insert([datos]).select();
  if (error) throw error;
  return data;
};