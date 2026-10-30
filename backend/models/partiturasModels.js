import { supabase } from '../config/supabase.js';

export const PartiturasModel = {
    // Crear categoría (esta ya la usa el admin y funciona bien)
    createCategoria: async (nombre_partitura, voz_partitura) => {
        const { data, error } = await supabase
            .from('categorias_partituras')
            .insert([{ nombre_partitura, voz_partitura }])
            .select('id_categoria, nombre_partitura, voz_partitura')
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

    // --- AQUÍ ESTÁ LA SOLUCIÓN ---
    // Consultamos directamente 'categorias_partituras' y lo envolvemos 
    // para que la app del usuario lo lea sin modificar Flutter.
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