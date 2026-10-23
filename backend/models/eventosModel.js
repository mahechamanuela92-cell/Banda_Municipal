import {supabase} from "../config/supabase.js";

//crear un evento
export const crearEvento = async (user_id, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion) => {
    const {data, error} = await supabase
        .from('eventos')
        .insert({user_id, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion})
        .select();
    return {data, error};
};

//obtener todos los eventos
export const obtenerEventos = async () => {
    const {data, error} = await supabase
        .from('eventos')
        .select('*')
        .order('fecha_evento', {ascending: true});

    return {data, error};
};

//obtener los eventos de un usuario
export const obtenerEventosPorUsuario = async (user_id) => {
    const {data, error} = await supabase
        .from('eventos')
        .select('*')
        .eq('user_id', user_id)
        .order('fecha_evento', {ascending: true});

    return {data, error};
};

//obtener un evento por id
export const obtenerEventoPorId = async (id_evento) => {
    const {data, error} = await supabase
        .from('eventos')
        .select('*')
        .eq('id_evento', id_evento)
        .single();

    return {data, error};
};

//editar un evento
export const editarEvento = async (id_evento, nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion) => {
    const {data, error} = await supabase
        .from('eventos')
        .update({nombre_evento, fecha_evento, hora_evento, lugar_evento, descripcion})
        .eq('id_evento', id_evento)
        .select();

    return {data, error};
};

//eliminar un evento
export const eliminarEvento = async (id_evento) => {
    const {data, error} = await supabase
        .from('eventos')
        .delete()
        .eq('id_evento', id_evento)
        .select();

    return {data, error};
};