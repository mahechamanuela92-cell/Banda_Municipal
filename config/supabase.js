// VARIABLES DE ENTORNO Y MODULOS
import dotenv from 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
<<<<<<< HEAD
=======
import WebSocket from 'ws';
>>>>>>> f09a87e058130ae1b00fc6d96e9a6ff4b61746c3

// creamos de la conexion a supabase
const supabaseurl = process.env.SUPABASE_URL;
const supabasekey = process.env.SUPABASE_KEY;

// variables de conexion
if (!supabaseurl || !supabasekey) {
    console.error("❌ error: las variables de entorno supabase_url y supabase_key son requeridas");
    process.exit(1);
}

<<<<<<< HEAD
// conexion a supabase
export const supabase = createClient(supabaseurl, supabasekey);

export const conectarDB = () => {
    console.log("✅ conexion a supabase establecida correctamente ");
};
 
=======
// conexion a supabase con WebSocket asignado correctamente
export const supabase = createClient(supabaseurl, supabasekey, {
    auth: {
        persistSession: false
    },
    realtime: {
        transport: WebSocket
    }
});

export const conectarDB = () => {
    console.log("✅ conexion a supabase establecida correctamente ");
};
>>>>>>> f09a87e058130ae1b00fc6d96e9a6ff4b61746c3
