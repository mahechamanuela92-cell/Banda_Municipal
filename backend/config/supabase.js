import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import WebSocket from 'ws';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ error: las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas");
  process.exit(1);
}

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