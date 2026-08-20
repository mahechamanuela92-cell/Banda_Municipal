// VARIABLES DE ENTORNO Y MODULOS
import dotenv from 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
<<<<<<< HEAD
=======
import WebSocket from 'ws';
>>>>>>> f09a87e058130ae1b00fc6d96e9a6ff4b61746c3

// creamos de la conexion a supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

// variables de conexion
if (!supabaseUrl || !supabaseKey) {
  console.error("❌ error: las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas");
  process.exit(1);
}

<<<<<<< HEAD:config/supabase.js
// conexion a supabase con WebSocket y Realtime
export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: false
  },
  realtime: {
    transport: WebSocket
  }
});

export const conectarDB = () => {
  console.log("✅ conexion a supabase establecida correctamente");
};
=======
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
>>>>>>> 1c001a320ebf03e3faddfea662ac130354f4f609:backend/config/supabase.js
