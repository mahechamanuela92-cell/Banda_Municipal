import { supabase } from "../config/supabase.js"; // Ajusta la ruta si tu cliente está en otra carpeta

function formatearTiempo(segundos) {
  const total = Math.max(0, Number(segundos) || 0);
  const mins = Math.floor(total / 60)
    .toString()
    .padStart(2, "0");
  const secs = (total % 60).toString().padStart(2, "0");
  return `${mins}:${secs}`;
}

export const guardarResultadoMemoria = async (req, res) => {
  try {
    const {
      nombre,
      correo,
      nivel = 1,
      puntos = 0,
      tiempoSegundos,
      intentos = 0,
    } = req.body;

    if (!nombre || !String(nombre).trim()) {
      return res
        .status(400)
        .json({ message: "El nombre del músico es obligatorio." });
    }

    const tiempoNum = Number(tiempoSegundos);
    if (!Number.isFinite(tiempoNum) || tiempoNum <= 0) {
      return res
        .status(400)
        .json({ message: "El tiempo en segundos debe ser mayor a 0." });
    }

    const nombreLimpio = String(nombre).trim();
    const nivelNum = Math.max(1, Number(nivel) || 1);
    const puntosNum = Math.max(0, Number(puntos) || 0);
    const intentosNum = Math.max(0, Number(intentos) || 0);

    // Buscar si ya existe un registro con ese nombre
    const { data: existente, error: errorConsulta } = await supabase
      .from("ranking_memoria")
      .select("*")
      .ilike("nombre", nombreLimpio)
      .maybeSingle();

    if (errorConsulta) {
      console.error("Error buscando en ranking_memoria:", errorConsulta.message);
      return res
        .status(500)
        .json({ message: "Error al consultar el ranking." });
    }

    if (existente) {
      const nuevosPuntos = Math.max(existente.puntos, puntosNum);
      const tiempoExistente = Number(existente.mejor_tiempo_segundos);
      const nuevoMejorTiempo =
        Number.isFinite(tiempoExistente) && tiempoExistente > 0
          ? Math.min(tiempoExistente, tiempoNum)
          : tiempoNum;
      const nuevoNivel = Math.max(existente.nivel, nivelNum);
      const mejoresIntentos =
        puntosNum >= existente.puntos ? intentosNum : existente.intentos;

      const { data: actualizado, error: errorUpdate } = await supabase
        .from("ranking_memoria")
        .update({
          correo: correo || existente.correo,
          nivel: nuevoNivel,
          puntos: nuevosPuntos,
          mejor_tiempo_segundos: nuevoMejorTiempo,
          intentos: mejoresIntentos,
          updated_at: new Date().toISOString(),
        })
        .eq("id", existente.id)
        .select()
        .single();

      if (errorUpdate) {
        console.error("Error actualizando ranking:", errorUpdate.message);
        return res
          .status(500)
          .json({ message: "Error al actualizar el puntaje." });
      }

      return res.status(200).json({
        message: "Puntaje guardado en el ranking.",
        registro: {
          ...actualizado,
          tiempo_formateado: formatearTiempo(actualizado.mejor_tiempo_segundos),
        },
      });
    }

    const { data: insertado, error: errorInsert } = await supabase
      .from("ranking_memoria")
      .insert([
        {
          nombre: nombreLimpio,
          correo: correo || null,
          nivel: nivelNum,
          puntos: puntosNum,
          mejor_tiempo_segundos: tiempoNum,
          intentos: intentosNum,
        },
      ])
      .select()
      .single();

    if (errorInsert) {
      console.error("Error insertando en ranking:", errorInsert.message);
      return res
        .status(500)
        .json({ message: "Error al guardar el puntaje." });
    }

    return res.status(201).json({
      message: "Puntaje registrado en el ranking.",
      registro: {
        ...insertado,
        tiempo_formateado: formatearTiempo(insertado.mejor_tiempo_segundos),
      },
    });
  } catch (error) {
    console.error("Error en guardarResultadoMemoria:", error);
    return res
      .status(500)
      .json({ message: "Error interno del servidor.", error: error.message });
  }
};

export const obtenerRankingMemoria = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("ranking_memoria")
      .select("id, nombre, nivel, puntos, mejor_tiempo_segundos, intentos, updated_at")
      .order("puntos", { ascending: false })
      .order("mejor_tiempo_segundos", { ascending: true })
      .order("intentos", { ascending: true });

    if (error) {
      console.error("Error obteniendo ranking:", error.message);
      return res
        .status(500)
        .json({ message: "Error al cargar el ranking." });
    }

    const rankingOrdenado = (data || []).map((item, index) => ({
      ...item,
      puesto: index + 1,
      tiempo_formateado: formatearTiempo(item.mejor_tiempo_segundos),
    }));

    return res.status(200).json({ ranking: rankingOrdenado });
  } catch (error) {
    console.error("Error en obtenerRankingMemoria:", error);
    return res
      .status(500)
      .json({ message: "Error interno del servidor.", error: error.message });
  }
};