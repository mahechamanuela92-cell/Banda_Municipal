import { BrevoClient } from "@getbrevo/brevo";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Obtener la ruta base del archivo actual
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Inicializamos el cliente de Brevo con tu API Key
const brevo = new BrevoClient({ apiKey: process.env.BREVO_API_KEY });

export const enviarCorreoRecuperacion = async (email, codigo) => {
  try {
    // Ruta hacia tu imagen local en backend/assets/images/logo.jpg
    const rutaImagen = path.join(__dirname, "../assets/images/logo.jpg");

    // Convertir la imagen local a Base64
    let logoBase64 = "";
    if (fs.existsSync(rutaImagen)) {
      const imagenBuffer = fs.readFileSync(rutaImagen);
      logoBase64 = `data:image/jpeg;base64,${imagenBuffer.toString("base64")}`;
    }

    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: "🔑 Código de Verificación - Recuperación de Contraseña",
      sender: {
        name: process.env.EMAIL_FROM_NAME || "Banda Municipal de Garzón",
        email: process.env.EMAIL_USER, // Tu correo registrado en Brevo
      },
      to: [{ email: email }],
      htmlContent: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #f0e6e6; border-radius: 12px; background-color: #ffffff;">
            
            ${
              logoBase64
                ? `
            <!-- Logo local renderizado con bordes redondeados (circulares) -->
            <div style="text-align: center; margin-bottom: 15px;">
                <img src="${logoBase64}" 
                     alt="Logo Banda Municipal" 
                     style="width: 100px; height: 100px; object-fit: cover; border-radius: 50%; border: 2px solid #d81b60; display: inline-block;" />
            </div>
            `
                : ""
            }

            <h2 style="color: #d81b60; text-align: center; margin-bottom: 5px; margin-top: 0;">Banda Municipal de Garzón</h2>
            <h3 style="color: #333333; text-align: center; margin-top: 0;">Recuperación de Contraseña</h3>
            
            <p style="color: #555555; font-size: 15px; text-align: center;">Has solicitado restablecer tu contraseña. Utiliza el siguiente código de verificación:</p>
            
            <div style="text-align: center; margin: 25px 0;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #d81b60; background: #fff8e1; padding: 12px 24px; border-radius: 8px; border: 2px dashed #fbc02d; display: inline-block;">
                    ${codigo}
                </span>
            </div>
            
            <p style="color: #888888; font-size: 12px; text-align: center; margin-top: 25px;">
                Este código es válido durante <strong>15 minutos</strong>. Si no solicitaste este cambio, puedes ignorar este mensaje.
            </p>
        </div>
      `,
    });

    console.log("Correo de recuperación enviado con éxito vía Brevo");
    return { success: true, result };
  } catch (error) {
    console.error("Error enviando correo de recuperación con Brevo:", error);
    return { success: false, error: error.message };
  }
};