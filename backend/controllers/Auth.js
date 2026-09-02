import bcrypt from 'bcrypt';
import jwt from "jsonwebtoken";
import { crearUser, obtenerPorEmail } from '../models/User.js';

export const registro = async (req, res) => {
  try {
    const { nombre, email, password } = req.body;

    if (!nombre || !email || !password) {
      
      return res.status(400).json({ error: "Faltan campos obligatorios" });
    }

    const { data: usuarioExiste } = await obtenerPorEmail(email);
    if (usuarioExiste) {
      return res.status(400).json({ error: "El email ya existe" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const rolPorDefecto = "musico";

    const { data, error } = await crearUser(nombre, email, hashedPassword, rolPorDefecto);

    if (error) {
      return res.status(500).json({ error: "Error al crear el usuario" });
    }

    return res.status(201).json({
      message: "Usuario registrado con éxito",
      usuario: {
        id: data[0].user_id,
        nombre: data[0].nombre,
        email: data[0].email,
        rol: data[0].rol
      }
    });
  } catch (error) {
    console.error("Error en registro:", error);
    return res.status(500).json({ error: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email y contraseña son requeridos" });
    }

    const { data: usuario, error } = await obtenerPorEmail(email);

    if (!usuario) {
      return res.status(400).json({ error: "El email no está registrado" });
    }

    const passwordValido = await bcrypt.compare(password, usuario.password);
    if (!passwordValido) {
      return res.status(400).json({ error: "Contraseña incorrecta" });
    }

    const token = jwt.sign(
      {
        id: usuario.user_id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol
      },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    return res.status(200).json({
      message: "Login exitoso",
      token: token,
      id: usuario.user_id,
      nombre: usuario.nombre,
      email: usuario.email,
      rol: usuario.rol
    });
  } catch (error) {
    console.error("Error en el login:", error);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};