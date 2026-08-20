import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

export const enviarCorreoRecuperacion = async (email, codigo) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: `🔑 Código de Verificación - Recuperación de Contraseña`,
    html: `
      <h2>Recuperación de Contraseña</h2>
      <p>Tu código de verificación para restablecer la contraseña es:</p>
      <h1 style="background-color: #f4f4f4; padding: 10px; display: inline-block; letter-spacing: 5px;">${codigo}</h1>
      <p>Este código expira en 15 minutos.</p>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: 'Correo enviado' };
  } catch (error) {
    console.error('Error al enviar correo:', error);
    return { success: false, error: error.message };
  }
};