import { supabase } from '../config/supabase.js';

// Generar código de registro de 6 dígitos (Solo Admin)
export const generarCodigoRegistro = async (req, res) => {
  try {
    // Generar número aleatorio de 6 dígitos
    const codigoGenerado = Math.floor(100000 + Math.random() * 900000).toString();

    // Guardarlo en la tabla codigos_invitacion
    const { data, error } = await supabase
      .from('codigos_invitacion')
      .insert([{ codigo: codigoGenerado, usado: false }])
      .select();

    if (error) {
      console.error("Error al guardar código en Supabase:", error);
      return res.status(500).json({ error: "Error al generar el código de registro" });
    }

    return res.status(201).json({
      message: "Código de registro generado con éxito",
      codigo: codigoGenerado
    });
  } catch (error) {
    console.error("Error en generarCodigoRegistro:", error);
    return res.status(500).json({ error: error.message });
  }
};