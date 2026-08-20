// Importar toda la funcionalidad
import express from 'express';
import dotenv from 'dotenv'; 
import cors from 'cors';
import { conectarDB } from './config/supabase.js';

// Importar rutas (Asegúrate de no duplicar "userRoutes")
import userRoutes from './routes/Auth.js';
import instrumentosRoutes from './routes/instrumentosRoutes.js';
import eventosRoutes from './routes/eventosRoutes.js';
import multimediaRoutes from './routes/multimediaRoutes.js';
import catalogoRoutes from './routes/catalogoRoutes.js';
import partiturasRoutes from './routes/partiturasRoutes.js';
import perfilRoutes from './routes/perfil.js';


// Cargar variables de entorno 
dotenv.config();

// Conectar a la base de datos
conectarDB();

// Crear la aplicación de express
const app = express();

// Middlewares
app.use(express.json());
app.use(cors());

// Ruta de bienvenida
app.get('/', (req, res) => {
    res.json({
        mensaje: 'Bienvenido al backend de la Banda Municipal',
        estado: 'en linea',
        version: '1.0.0'
    });
});
// Registrar rutas
app.use('/usuarios', userRoutes); // Dentro de Auth.js ya tienes /forgot-password y /verify-code
app.use('/perfil', perfilRoutes);
app.use('/instrumentos', instrumentosRoutes);
app.use('/eventos', eventosRoutes);
app.use('/multimedia', multimediaRoutes);
app.use('/catalogo', catalogoRoutes);
app.use('/partituras', partiturasRoutes);


// Middleware para manejar rutas no encontradas (404)
app.use((req, res) => {
    res.status(404).json({ error: 'Ruta no encontrada' });
});

// Configurar el puerto
const PORT = process.env.PORT || 3000;

// Poner a escuchar el servidor
app.listen(PORT, () => {
    console.log(`Servidor escuchando en el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});