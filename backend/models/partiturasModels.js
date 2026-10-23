import { supabase } from '../config/supabase.js';

export const PartiturasModel = {
    // Crear categoría (ya la tienes funcionando)
    createCategoria: async (nombre_partitura, voz_partitura) => {
        const { data, error } = await supabase
            .from('categorias_partituras')
            .insert([{ nombre_partitura, voz_partitura }])
            .select('id_categoria, nombre_partitura, voz_partitura')
            .single();

        if (error) throw error;
        return data;
    },

    // Crear partitura usando id_listado e id_categoria
    createPartitura: async (id_listado, id_categoria) => {
        const { data, error } = await supabase
            .from('partituras')
            .insert([{ id_listado, id_categoria }])
            .select('id_partitura, id_listado, id_categoria')
            .single();

        if (error) throw error;
        return data;
    },

    // Obtener todas las partituras cruzando los datos con categorías
    getAll: async () => {
        const { data, error } = await supabase
            .from('partituras')
            .select(`
                id_partitura,
                id_listado,
                categorias_partituras (
                    id_categoria,
                    nombre_partitura,
                    voz_partitura
                )
            `)
            .order('id_partitura', { ascending: false });

        if (error) throw error;
        return data;
    },

    getByCategoria: async (id_categoria) => {
        const { data, error } = await supabase
            .from('partituras')
            .select(`
                id_partitura,
                id_listado,
                categorias_partituras (
                    id_categoria,
                    nombre_partitura,
                    voz_partitura
                )
            `)
            .eq('id_categoria', id_categoria);

        if (error) throw error;
        return data;
    }
};