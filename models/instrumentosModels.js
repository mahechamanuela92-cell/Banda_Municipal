import { supabase } from '../config/supabase.js';

export const InstrumentosModel = {
    // 1. Crear instrumento principal (Número de serial)
    createInstrumento: async (numero_serial) => {
        const { data, error } = await supabase
            .from('instrumentos')
            .insert([{ numero_serial }])
            .select('id_instrumentos, numero_serial')
            .single();

        if (error) throw error;
        return data;
    },

    // 2. Crear detalle en listado_instrumentos
    createDetalle: async (id_instrumentos, nombre_de_instrumento, instrumento_en) => {
        const { data, error } = await supabase
            .from('listado_instrumentos')
            .insert([{ id_instrumentos, nombre_de_instrumento, instrumento_en }])
            .select('id_listado, id_instrumentos, nombre_de_instrumento, instrumento_en')
            .single();

        if (error) throw error;
        return data;
    },

    // 3. Obtener todos los instrumentos con su detalle (Equivalente al INNER JOIN)
    getAll: async () => {
        const { data, error } = await supabase
            .from('instrumentos')
            .select(`
                id_instrumentos,
                numero_serial,
                listado_instrumentos (
                    id_listado,
                    nombre_de_instrumento,
                    instrumento_en
                )
            `)
            .order('id_instrumentos', { ascending: false });

        if (error) throw error;
        return data;
    },

    // 4. Actualizar estado de un instrumento
    updateEstado: async (id_listado, nuevo_estado) => {
        const { data, error } = await supabase
            .from('listado_instrumentos')
            .update({ instrumento_en: nuevo_estado })
            .eq('id_listado', id_listado)
            .select()
            .single();

        if (error) throw error;
        return data;
    }
};