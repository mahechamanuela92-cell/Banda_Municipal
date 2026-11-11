import { supabase } from '../config/supabase.js';

export const PartiturasModel = {
    // Crear categoría (Incluyendo el archivo_url que subió el admin)
    createCategoria: async (nombre_partitura, voz_partitura, archivo_url) => {
        const { data, error } = await supabase
            .from('categorias_partituras')
            .insert([{ nombre_partitura, voz_partitura, archivo_url }]) // 🌟 Agregamos la URL del archivo aquí
            .select('id_categoria, nombre_partitura, voz_partitura, archivo_url')
            .single();

        if (error) throw error;
        return data;
    },

    createPartitura: async (id_listado, id_categoria) => {
        const { data, error } = await supabase
            .from('partituras')
            .insert([{ id_listado, id_categoria }])
            .select('id_partitura, id_listado, id_categoria')
            .single();

        if (error) throw error;
        return data;
    },

    // Consultar todas las categorías (traerá automáticamente la `archivo_url`)
    getAll: async () => {
        const { data, error } = await supabase
            .from('categorias_partituras')
            .select('*')
            .order('id_categoria', { ascending: false });

        if (error) throw error;

        // Mapeamos para que mantenga la estructura que Flutter ya espera
        return data.map(categoria => ({
            categorias_partituras: categoria
        }));
    },

    getByCategoria: async (id_categoria) => {
        const { data, error } = await supabase
            .from('categorias_partituras')
            .select('*')
            .eq('id_categoria', id_categoria);

        if (error) throw error;
        return data.map(categoria => ({
            categorias_partituras: categoria
        }));
    }
};