import {supabase} from "../config/supabase.js";

//crear el usuario
export const crearusuario = async (nombre, email, password, rol) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({nombre, email, password, rol}) 
        .select('id,nombre,email,rol')
        return {data, error};
    };

//obtener usuarios
export const obtenerUsuarios = async () => {
    const{data,error} =await supabase
    .from('usuarios')
    .select('id, nombre, email, rol');
    
    return{data,error};
};

//buscar el usuario por email para el login 

export const obtenerPorEmail =async (email)=>{
    const {data,error}= await supabase
    .from ('usuarios')
    .select('*')
    .eq('email', email)
    .single();
    return{data,error};

};
//obtener usuario por id
export const obtenerUsuarioPorId = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, nombre, email, rol')
        .eq('id', id)
        .single();
    return { data, error };
};
//actulizar usuario
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select('id, nombre, email, rol');
    return { data, error };

};
//eliminar usuario
export const eliminarUsuario = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id)
        .select('id, nombre, email, rol');
    return { data, error };
};