import bcrypt from 'bcrypt'; // <-- 1. Importación que faltaba
import { RecuperarModel } from '../models/recuperar.js';
import { enviarCorreoRecuperacion } from '../utils/sendEmails.js';

const generarCodigo = () => Math.floor(100000 + Math.random() * 900000).toString();

export const olvidarPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "El email es requerido" });
    }

    const usuario = await RecuperarModel.findUserByEmail(email);
    if (!usuario) {
      return res.status(400).json({ error: "El email no está registrado" });
    }

    const codigo = generarCodigo();
    const expires = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    // 2. Cambiado usuario.id por usuario.user_id
    await RecuperarModel.saveResetCode(usuario.user_id, codigo, expires);

    const emailResult = await enviarCorreoRecuperacion(email, codigo);
    if (!emailResult.success) {
      return res.status(500).json({ error: "Error al enviar el correo" });
    }

    return res.status(200).json({ message: "Código enviado al correo con éxito" });
  } catch (error) {
    console.error("Error en olvidarPassword:", error);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};

export const verifyCode = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({ error: "Todos los campos son requeridos" });
    }

    const usuario = await RecuperarModel.findUserByEmail(email);
    if (!usuario) {
      return res.status(400).json({ error: "Usuario no encontrado" });
    }

    if (usuario.reset_code !== code) {
      return res.status(400).json({ error: "Código incorrecto" });
    }

    if (new Date(usuario.reset_expires) < new Date()) {
      return res.status(400).json({ error: "El código ha expirado" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    // 3. Cambiado usuario.id por usuario.user_id
    await RecuperarModel.updatePassword(usuario.user_id, hashedPassword);

    return res.status(200).json({ message: "Contraseña actualizada con éxito" });
  } catch (error) {
    console.error("Error en verifyCode:", error);
    return res.status(500).json({ error: "Error en el servidor" });
  }
};