//importar toda la funcionalidad de express
import express from 'express';
import dotenv from 'dotenv'; 
import { conectarDB } from './config/supabase.js';
import userRoutes from './routes/Auth.js';
import instrumentosRoutes from './routes/instrumentosRoutes.js';
import cors from 'cors';
import eventosRoutes from './routes/eventosRoutes.js';
import multimediaRoutes from './routes/multimediaRoutes.js';
import catalogoRoutes from './routes/catalogoRoutes.js';

//cargar variables de entorno 
dotenv.config();

//creamos la aplicacion de express
const app = express();

// middlewares
app.use(express.json());
app.use(cors());

// ruta de bienvenida
app.get('/', (req, res) => {
    res.json({
        mensaje: 'bienvenido al backend de la Banda Municipal',
        estado: 'en linea',
        version: '1.0.0'
    });
});

// registrar rutas
app.use('/usuarios', userRoutes);
app.use('/instrumentos', instrumentosRoutes);
app.use('/eventos', eventosRoutes);
app.use('/multimedia', multimediaRoutes);
app.use('/catalogo', catalogoRoutes);

// configuramos el puerto
const PORT = process.env.PORT || 3000;

// poner a escuchar el servidor
app.listen(PORT, () => {
    conectarDB();
    console.log(`Servidor escuchando en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});