import bcrypt from 'bcrypt';
import jwt from "jsonwebtoken";
import {supabase} from '../config/supabase.js';
import { crearUser, obtenerPorEmail } from '../models/User.js';
import {enviarCodigoVerificacion} from '../utils/emailService.js';

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
    //generar codigo de verificacion con math.random() y fecha de expiracion (15 minutos)
    const codigoVerificacion = Math.floor(100000 + Math.random() * 900000).toString();
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000).toString();
    //guardar en supabase enviando los nuevos campos
    const { data, error } = await crearUser(
      nombre, 
      email, 
      hashedPassword, 
      rolPorDefecto,
      codigoVerificacion,
      codigoVerificacionExpiracion
      );

    if (error) {
      return res.status(500).json({ error: "Error al crear el usuario" });
    }
    // enviar el correo con el codigo de 6 digitos usando Brevo
    const resultadoEnvio = await enviarCodigoVerificacion(email,nombre,codigoVerificacion);
    // normalizar el objeto de usuario (soporta dormato con o sin .single)
    const usuarioCreado = Array.isArray(data) ? data[0] : data;
    const usuarioRespuesta = {
      id: usuarioCreado.id,
      nombre: usuarioCreado.nombre,
      email: usuarioCreado.email,
      rol: usuarioCreado.rol
    };
    //si brevo fallo, el usuario ya quedo creado, pero avisamos que el correo no llego
    if (!resultadoEnvio.exito) {
      return res.status(201).json({
        message: 'Tu cuenta fue creada, pero hubo un problema enviando el codigo de verificacion a tu correo. Intenta registrar de nuevo en unos minutos o contacta soporte.',
        emailEnviado: false,
        usuario: usuarioRespuesta
      });
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
//verificar cuenta con codigo de 6 digitos
export const verificarCuenta = async (req, res) => {
  try {
    const {email, codigo} = req.body;
      if (!email || !codigo) {
        return res.status(400).json({
          error: 'El email y el codigo de verificacion son requeridos'
        });
      }
      //1 buscar al usuario en supabase 
      const {data: usuario, error: errorUsuario} = await supabase
      .from('usuario')
      .select('id, email, isVerified, codigoVerificacion, codigoVerificacionExpiracion')
      .eq('email', email)
      .single();
      if (errorUsuario || !usuario){
        return res.status(404).json({
          error: 'Usuario no encontrado'
        });
      }
      //2. revisar si ya esta activo
      if (usuario.isVerified){
        return res.status(400).json({
          error: 'La cuenta ya se encuentra verificada'
        });
      }
      //3. comparar el codigo
      if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()){
        return res.status(400).json({
          error: 'El codigo de verificacion es incorrecto'
        });
      }
      //4. velidar expiracion (15 minutos)
      const ahora = new Date();
      const expiracion = new Date(usuario.codigoVerificacionExpiracion);
      if (ahora > expiracion){
        return res.status(400).json({
          error: 'El codigo ha expirado. Por favor solicita uno nuevo'
        });
      }
      //5. activar la cuenta
      const {error: errorDate} = await supabase
      .from('usuarios')
      .update({
        isVerfied: true,
        codigoVerificacion: null,
        codigoVerificacionExpiracion: null
      })
      .eq('id', usuario.id);

      if (errorUpdate){
        return res.status(500).json({
          error: 'Error al actualizar el estado de verificacion'
        });
      }
      return res.status(200).json({
        message: 'Cuenta verificada exitosamente. Ya puedes iniciar sesion en Banda Sinfonica Municipal de Garzon Huila'
      });
  } catch (error) {
    console.error('Error en verificarCuenta:', error);
    return res.status(500).json({
      error: error.message
    });
  }
};