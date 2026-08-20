import { AuthModel } from '../models/Auth.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const register = async (req, res) => {
    const { nombre, email, contrasena, rol } = req.body;

    try {
        const userExists = await AuthModel.findByEmail(email);
        if (userExists) {
            return res.status(400).json({ message: 'El correo ya está registrado' });
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(contrasena, saltRounds);

        // Se envía hashedPassword a la columna 'password' del modelo
        const newUser = await AuthModel.createUser(
            nombre, 
            email, 
            hashedPassword, 
            rol || 'Usuario'
        );

        res.status(201).json({
            message: 'Usuario registrado con éxito',
            user: newUser
        });
    } catch (error) {
        console.error('Error en register:', error);
        res.status(500).json({ 
            message: 'Error en el servidor', 
            error: error.message || error 
        });
    }
};

export const login = async (req, res) => {
    const { email, contrasena } = req.body;

    try {
        const user = await AuthModel.findByEmail(email);
        if (!user) {
            return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        // Se compara con user.password
        const isMatch = await bcrypt.compare(contrasena, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Contraseña incorrecta' });
        }

        const token = jwt.sign(
            { user_id: user.user_id, rol: user.rol },
            process.env.JWT_SECRET || 'secreto_super_seguro',
            { expiresIn: '8h' }
        );

        res.json({
            message: 'Inicio de sesión exitoso',
            token,
            user: {
                user_id: user.user_id,
                nombre: user.nombre,
                email: user.email,
                rol: user.rol
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Error en el servidor', error: error.message });
    }
};