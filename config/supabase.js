// VARIABLES DE ENTORNO Y MODULOS
import dotenv from 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import WebSocket from 'ws';

// creamos de la conexion a supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

// variables de conexion
if (!supabaseUrl || !supabaseKey) {
  console.error("❌ error: las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas");
  process.exit(1);
}

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
