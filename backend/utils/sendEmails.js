export const enviarCorreoRecuperacion = async (email, codigo) => {
  try {
    // 1. HTML con tablas (compatible con Gmail, Outlook, etc.), sin imagen
    const htmlContent = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Recuperación de Contraseña</title>
</head>
<body style="margin:0; padding:0; background-color:#f4f7f6; font-family:Arial, Helvetica, sans-serif;">
  <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#f4f7f6" style="background-color:#f4f7f6;">
    <tr>
      <td align="center" style="padding:20px 10px;">

        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="500" bgcolor="#ffffff" style="width:100%; max-width:500px; background-color:#ffffff; border:1px solid #e8e8e8; border-radius:12px;">

          <!-- Encabezado -->
          <tr>
            <td align="center" bgcolor="#d81b60" style="background-color:#d81b60; padding:30px 20px; border-radius:12px 12px 0 0;">
              <h1 style="color:#ffffff; font-size:20px; margin:0; font-weight:bold; font-family:Arial, Helvetica, sans-serif;">
                Banda Municipal de Garzón
              </h1>
            </td>
          </tr>

          <!-- Contenido principal -->
          <tr>
            <td align="center" style="padding:30px 40px;">
              <h2 style="color:#333333; font-size:20px; margin:0 0 15px 0; font-family:Arial, Helvetica, sans-serif;">
                Recuperación de Contraseña
              </h2>
              <p style="color:#555555; font-size:14px; line-height:22px; margin:0 0 20px 0;">
                Has solicitado restablecer tu contraseña. Utiliza el siguiente código de verificación:
              </p>

              <!-- Código -->
              <table role="presentation" border="0" cellpadding="0" cellspacing="0" align="center" style="margin:20px auto;">
                <tr>
                  <td align="center" bgcolor="#fff8f9" style="background-color:#fff8f9; border:2px dashed #f8bbd0; border-radius:8px; padding:12px 24px;">
                    <span style="font-size:30px; font-weight:bold; letter-spacing:6px; color:#d81b60; font-family:Arial, Helvetica, sans-serif;">
                      ${codigo}
                    </span>
                  </td>
                </tr>
              </table>

              <p style="color:#888888; font-size:12px; line-height:18px; margin:25px 0 0 0;">
                Este código es válido durante <strong>15 minutos</strong>.<br>
                Si no solicitaste este cambio, ignora este mensaje.
              </p>
            </td>
          </tr>

          <!-- Pie de página -->
          <tr>
            <td align="center" bgcolor="#fafafa" style="background-color:#fafafa; padding:15px; border-top:1px solid #eeeeee; border-radius:0 0 12px 12px;">
              <p style="color:#aaaaaa; font-size:11px; margin:0;">
                © Banda Sinfónica Municipal de Garzón
              </p>
            </td>
          </tr>

        </table>

      </td>
    </tr>
  </table>
</body>
</html>`;

    // 2. Configurar un controlador con 30 segundos de timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000);

    // 3. Enviar mediante la API REST oficial de Brevo
    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'api-key': process.env.BREVO_API_KEY
      },
      body: JSON.stringify({
        sender: {
          name: process.env.EMAIL_FROM_NAME || "Banda Municipal de Garzón",
          email: process.env.EMAIL_USER
        },
        to: [{ email: email }],
        subject: "🔑 Código de Verificación - Recuperación de Contraseña",
        htmlContent: htmlContent
      }),
      signal: controller.signal
    });

    clearTimeout(timeoutId);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || 'Error al comunicarse con la API de Brevo');
    }

    console.log('✅ Correo de recuperación enviado con éxito vía Brevo:', data);
    return { success: true, data };
  } catch (error) {
    if (error.name === 'AbortError') {
      console.error('❌ Error: La conexión con Brevo tardó demasiado (Timeout de 30s).');
    } else {
      console.error('❌ Error enviando correo de recuperación con Brevo:', error);
    }
    return { success: false, error: error.message || error };
  }
};