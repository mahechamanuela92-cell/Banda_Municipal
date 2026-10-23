import {supabase} from "../config/supabase.js";

//guardar una url de foto o video
export const guardarMultimedia = async (user_id, id_evento, titulo, tipo_archivo, url_archivo) => {
    const {data, error} = await supabase
        .from('multimedia')
        .insert({user_id, id_evento, titulo, tipo_archivo, url_archivo})
        .select();

    return {data, error};
};

//obtener todo el multimedia
export const obtenerMultimedia = async () => {
    const {data, error} = await supabase
        .from('multimedia')
        .select('*')
        .order('fecha_subida', {ascending: false});

    return {data, error};
};

//filtrar multimedia por evento
export const filtrarPorEvento = async (id_evento) => {
    const {data, error} = await supabase
        .from('multimedia')
        .select('*')
        .eq('id_evento', id_evento)
        .order('fecha_subida', {ascending: false});

    return {data, error};
};

//filtrar multimedia por tipo (foto o video)
export const filtrarPorTipo = async (tipo_archivo) => {
    const {data, error} = await supabase
        .from('multimedia')
        .select('*')
        .eq('tipo_archivo', tipo_archivo)
        .order('fecha_subida', {ascending: false});

    return {data, error};
};

//eliminar un archivo multimedia
export const eliminarMultimedia = async (id_multimedia) => {
    const {data, error} = await supabase
        .from('multimedia')
        .delete()
        .eq('id_multimedia', id_multimedia)
        .select();

    return {data, error};
};