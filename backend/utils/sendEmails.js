import nodemailer from 'nodemailer';
import path from 'path';
import { fileURLToPath } from 'url';

// Esto ayuda a calcular la ruta correcta de tu archivo local
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

export const enviarCorreoRecuperacion = async (email, codigo) => {
  const mailOptions = {
    from: `"Banda Municipal de Garzón" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: `🔑 Código de Verificación - Recuperación de Contraseña`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; }
          .container { max-width: 500px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.08); border: 1px solid #eee; }
          .header { background: linear-gradient(135deg, #d81b60 0%, #8e24aa 100%); padding: 25px; text-align: center; }
          .logo { max-width: 130px; height: auto; display: block; margin: 0 auto; border: 0; }
          .content { padding: 30px 25px; text-align: center; color: #333333; }
          .title { font-size: 20px; font-weight: bold; color: #ad1457; margin-bottom: 10px; }
          .text { font-size: 14px; color: #555555; line-height: 1.5; margin-bottom: 25px; }
          .code-container { background: #fff8e1; border: 2px dashed #fbc02d; border-radius: 8px; padding: 15px; display: inline-block; margin-bottom: 25px; }
          .code { font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #d81b60; margin: 0; }
          .footer { background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; color: #777777; border-top: 1px solid #eeeeee; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <!-- Aquí usamos el identificador cid para la imagen adjunta -->
            <img src="cid:logo_banda" alt="Banda Municipal de Garzón" class="logo" />
          </div>
          <div class="content">
            <div class="title">Recuperación de Contraseña</div>
            <p class="text">Has solicitado restablecer tu contraseña. Utiliza el siguiente código de verificación para continuar con el proceso:</p>
            <div class="code-container">
              <span class="code">${codigo}</span>
            </div>
            <p class="text" style="font-size: 12px; color: #888888; margin-bottom: 0;">Este código es válido durante <strong>15 minutos</strong>. Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
          </div>
          <div class="footer">
            <p style="margin: 0;">Banda Municipal de Garzón &copy; ${new Date().getFullYear()}</p>
          </div>
        </div>
      </body>
      </html>
    `,
    // Aquí es donde vinculamos físicamente la imagen de tu carpeta assets
    attachments: [{
      filename: 'logo.jpg',
      path: path.join(__dirname, '../assets/logo.jpg'), // Ajusta si tu carpeta assets está en otro nivel
      cid: 'logo_banda' // Debe coincidir con el src="cid:logo_banda" de arriba
    }]
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: 'Correo enviado' };
  } catch (error) {
    console.error('Error al enviar correo:', error);
    return { success: false, error: error.message };
  }
};