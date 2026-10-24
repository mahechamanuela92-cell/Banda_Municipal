import bcrypt from 'bcrypt';
import jwt from "jsonwebtoken";
import { supabase } from '../config/supabase.js';
import { crearUser, obtenerPorEmail } from '../models/User.js';
import { enviarCodigoVerificacion } from '../utils/emailService.js';

export const registro = async (req, res) => {
  console.log("🔥 ¡LLEGÓ UNA PETICIÓN DESDE EL CELULAR AL BACKEND! 🔥");

  try {
    const { nombre, email, password, tipo_documento, numero_documento, telefono, codigoInvitacion } = req.body;

    if (!nombre || !email || !password || !codigoInvitacion) {
      return res.status(400).json({ error: "Faltan campos obligatorios" });
    }

    // Validar el código de invitación generado por el administrador
    const { data: invitacion } = await supabase
      .from('codigos_invitacion')
      .select('id, usado')
      .eq('codigo', String(codigoInvitacion).trim())
      .maybeSingle();

    if (!invitacion) {
      return res.status(400).json({ error: "El código de registro no es válido" });
    }
    if (invitacion.usado) {
      return res.status(400).json({ error: "El código de registro ya fue usado" });
    }

    const { data: usuarioExiste } = await obtenerPorEmail(email);
    if (usuarioExiste) {
      return res.status(400).json({ error: "El email ya existe" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const rolPorDefecto = "musico";
    
    // Generar código de verificación y fecha de expiración (15 minutos)
    const codigoVerificacion = Math.floor(100000 + Math.random() * 900000).toString();
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    // Guardar en Supabase enviando los nuevos campos
    const { data, error } = await crearUser(
      nombre, 
      email, 
      hashedPassword, 
      rolPorDefecto,
      codigoVerificacion,
      codigoVerificacionExpiracion,
      tipo_documento,
      numero_documento,
      telefono
    );

    if (error) {
      console.error("❌ Error detallado de Supabase:", error);
      return res.status(500).json({ error: error.message || "Error al crear el usuario" });
    }

    // Asegurarnos de que data tenga elementos antes de usarlos
    if (!data || data.length === 0) {
      return res.status(500).json({ error: "No se pudo retornar el usuario creado" });
    }

    // Marcar el código de invitación como usado
    await supabase
      .from('codigos_invitacion')
      .update({ usado: true })
      .eq('id', invitacion.id);

    // Enviar el correo con el código de 6 dígitos usando Brevo
    const resultadoEnvio = await enviarCodigoVerificacion(email, nombre, codigoVerificacion);

    // Normalizar el objeto de usuario
    const usuarioCreado = Array.isArray(data) ? data[0] : data;
    const usuarioRespuesta = {
      id: usuarioCreado.user_id || usuarioCreado.id,
      nombre: usuarioCreado.nombre,
      email: usuarioCreado.email,
      rol: usuarioCreado.rol
    };

    // Si Brevo falló, el usuario ya quedó creado, pero avisamos que el correo no llegó
    if (!resultadoEnvio.exito) {
      return res.status(201).json({
        message: 'Tu cuenta fue creada, pero hubo un problema enviando el código de verificación a tu correo. Intenta registrar de nuevo en unos minutos o contacta soporte.',
        emailEnviado: false,
        usuario: usuarioRespuesta
      });
    }

    return res.status(201).json({
      message: "Usuario registrado con éxito. Revisa tu correo para verificar la cuenta.",
      usuario: usuarioRespuesta
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

// Verificar cuenta con código de 6 dígitos
export const verificarCuenta = async (req, res) => {
  try {
    const { email, codigo } = req.body;
    
    if (!email || !codigo) {
      return res.status(400).json({
        error: 'El email y el código de verificación son requeridos'
      });
    }

    // 1. Buscar al usuario en Supabase
    const { data: usuario, error: errorUsuario } = await supabase
      .from('usuarios')
      .select('user_id, email, isVerified, codigoVerificacion, codigoverificacionExpiracion')
      .eq('email', email)
      .single();

    if (errorUsuario || !usuario) {
      return res.status(404).json({
        error: 'Usuario no encontrado'
      });
    }

    // 2. Revisar si ya está activo
    if (usuario.isVerified) {
      return res.status(400).json({
        error: 'La cuenta ya se encuentra verificada'
      });
    }

    // 3. Comparar el código
    if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()) {
      return res.status(400).json({
        error: 'El código de verificación es incorrecto'
      });
    }

    // 4. Validar expiración (15 minutos)
    const ahora = new Date();
    const expiracion = new Date(usuario.codigoverificacionExpiracion);
    if (ahora > expiracion) {
      return res.status(400).json({
        error: 'El código ha expirado. Por favor solicita uno nuevo'
      });
    }

    // 5. Activar la cuenta
    const { error: errorUpdate } = await supabase
      .from('usuarios')
      .update({
        isVerified: true,
        codigoVerificacion: null,
        codigoverificacionExpiracion: null
      })
      .eq('user_id', usuario.user_id);

    if (errorUpdate) {
      return res.status(500).json({
        error: 'Error al actualizar el estado de verificación'
      });
    }

    return res.status(200).json({
      message: 'Cuenta verificada exitosamente. Ya puedes iniciar sesión en Banda Sinfónica Municipal de Garzón Huila'
    });

  } catch (error) {
    console.error('Error en verificarCuenta:', error);
    return res.status(500).json({
      error: error.message
    });
  }
};