import { AuthModel } from '../models/Auth.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const register = async (req, res) => {
    const { nombre, correo, contrasena, rol } = req.body;

    try {
        const userExists = await AuthModel.findByEmail(correo);
        if (userExists) {
            return res.status(400).json({ message: 'El correo ya está registrado' });
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(contrasena, saltRounds);

        const newUser = await AuthModel.createUser(
            nombre, 
            correo, 
            hashedPassword, 
            rol || 'Usuario'
        );

        res.status(201).json({
            message: 'Usuario registrado con éxito',
            user: newUser
        });
    } catch (error) {
        res.status(500).json({ message: 'Error en el servidor', error: error.message });
    }
};

export const login = async (req, res) => {
    const { correo, contrasena } = req.body;

    try {
        const user = await AuthModel.findByEmail(correo);
        if (!user) {
            return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const isMatch = await bcrypt.compare(contrasena, user.contrasena);
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
                correo: user.correo,
                rol: user.rol
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Error en el servidor', error: error.message });
    }
};