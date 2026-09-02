import {supabase} from "../config/supabase.js";

// categorias 

//obtener todas las categorias
export const obtenerCategorias = async () => {
    const {data, error} = await supabase
        .from('categorias_instrumentos')
        .select('*')
        .order('nombre_categoria', {ascending: true}); 

    return {data, error};
};

//crear una categoria
export const crearCategoria = async (nombre_categoria) => {
    const {data, error} = await supabase
        .from('categorias_instrumentos')
        .insert({nombre_categoria})
        .select();

    return {data, error};
};

//catalogo de instrumentos 

//obtener el catalogo completo (con el nombre de la categoria)
export const obtenerCatalogo = async () => {
    const {data, error} = await supabase
        .from('catalogo_instrumentos')
        .select('*, categorias_instrumentos(nombre_categoria)')
        .order('nombre_instrumento', {ascending: true});

    return {data, error};
};

//obtener el catalogo filtrado por categoria
export const obtenerCatalogoPorCategoria = async (id_categoria) => {
    const {data, error} = await supabase
        .from('catalogo_instrumentos')
        .select('*')
        .eq('id_categoria', id_categoria)
        .order('nombre_instrumento', {ascending: true});

    return {data, error};
};

//guardar un instrumento con url de imagen y audio
export const guardarInstrumentoCatalogo = async (id_categoria, nombre_instrumento, descripcion, url_imagen, url_audio) => {
    const {data, error} = await supabase
        .from('catalogo_instrumentos')
        .insert({id_categoria, nombre_instrumento, descripcion, url_imagen, url_audio})
        .select();

    return {data, error};
};

//eliminar un instrumento del catalogo
export const eliminarInstrumentoCatalogo = async (id_catalogo) => {
    const {data, error} = await supabase
        .from('catalogo_instrumentos')
        .delete()
        .eq('id_catalogo', id_catalogo)
        .select();

    return {data, error};
};