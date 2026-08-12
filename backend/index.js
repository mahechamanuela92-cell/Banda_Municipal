//importar toda la funcionalida de express
import express from 'express';
import dotenv from 'dotenv'; 
import { conectarDB, supabase} from './config/supabase.js';
import userRoutes from './routes/user.js';
import cors from 'cors';

//cargar variable de entorno 
dotenv.config();


//creamos la aplicacion de express
const app = express();

// leer el json
app.use(express.json());
app.use(cors());

// creamos la ruta
app.get('/', (req, res) => {
    res.json({
        mensaje: 'bienvenido al backend de MIMOS',
        estado: 'en linea',
        version: '1.0.0'
    });
});
//ruta de autenticacion 
app.use('/usuarios', userRoutes);

// configuramos el puerto
const PORT = 3000;

// poner a escuchar el servidor
app.listen(PORT, () => {
    conectarDB(); // Llama a la función para ver el mensaje en consola al iniciar
    console.log(`Servidor escuchando en el puerto ${PORT}`); // Corregido a backticks ``
    console.log(`http://localhost:${PORT}`);
});