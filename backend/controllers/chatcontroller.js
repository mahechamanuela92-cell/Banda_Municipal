import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js"; // Ruta a tu cliente de Supabase existente

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatBanda = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    // Si el cliente no manda sesion, creamos un identificador temporal
    const idSesionValido = sesionId || `banda_sesion_${Date.now()}`;

    // 1. Obtener partituras, eventos e instrumentos desde Supabase
    const [
      { data: partituras, error: errorPartituras },
      { data: eventos, error: errorEventos },
      { data: instrumentos, error: errorInstrumentos },
    ] = await Promise.all([
      supabase
        .from("partituras")
        .select("id_partitura, id_listado, id_categoria"),
      supabase
        .from("eventos")
        .select(
          "id_evento, user_id, nombre_evento, hora_evento, fecha_evento, lugar_evento, descripcion"
        ),
      supabase
        .from("instrumentos")
        .select("id_instrumentos, numero_serial"),
    ]);

    if (errorPartituras || errorEventos || errorInstrumentos) {
      console.error(
        "Error al consultar Supabase:",
        errorPartituras?.message || errorEventos?.message || errorInstrumentos?.message
      );
      return res.status(500).json({ message: "Error al consultar la información de la banda." });
    }

    const hayPartituras = partituras && partituras.length > 0;
    const hayEventos = eventos && eventos.length > 0;
    const hayInstrumentos = instrumentos && instrumentos.length > 0;

    if (!hayPartituras && !hayEventos && !hayInstrumentos) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos partituras, eventos ni instrumentos registrados.",
        sesionId: idSesionValido,
      });
    }

    // 2. Armar el texto de recursos para la IA
    const partiturasTexto = hayPartituras
      ? partituras
          .map(
            (p) =>
              `- Partitura #${p.id_partitura} | Listado: ${p.id_listado} | Categoría: ${p.id_categoria}`
          )
          .join("\n")
      : "No hay partituras registradas.";

    const eventosTexto = hayEventos
      ? eventos
          .map(
            (e) =>
              `- **${e.nombre_evento}**: ${e.fecha_evento} ${
                e.hora_evento ? `a las ${e.hora_evento}` : ""
              } en ${e.lugar_evento || "lugar por confirmar"}. ${e.descripcion || ""}`
          )
          .join("\n")
      : "No hay eventos programados.";

    const instrumentosTexto = hayInstrumentos
      ? instrumentos
          .map((i) => `- Instrumento #${i.id_instrumentos} | Serial: ${i.numero_serial}`)
          .join("\n")
      : "No hay instrumentos registrados.";

    const recursosTexto = `
PARTITURAS:
${partiturasTexto}

EVENTOS:
${eventosTexto}

INVENTARIO DE INSTRUMENTOS:
${instrumentosTexto}
`;

    const systemPrompt = `
Eres el asistente virtual y coordinador de la Banda Musical Municipal.
Eres servicial, organizado, entusiasta y respetuoso con la comunidad artística.

INFORMACIÓN ACTUAL DE LA BANDA (Partituras, Eventos e Inventario):
${recursosTexto}

REGLAS DE ATENCIÓN:
1. Si el usuario solo saluda (ej: "Hola", "¿Cómo estás?"), responde con cortesía sin desplegar listas ni detalles completos:
   "¡Hola! Bienvenido a la app de la Banda Musical Municipal 🎶. Qué gusto tenerte aquí, ¿en qué te puedo ayudar hoy ?"
2. Proporciona detalles de partituras, inventario de instrumentos o programación de eventos ÚNICAMENTE cuando el usuario lo solicite expresamente.
3. Sé claro al indicar las fechas, horarios de ensayo y disponibilidad de los instrumentos o materiales.
4. Sé conciso y completa tus oraciones.
`;

    // 3. Inferencia con Groq
    const completion = await groq.chat.completions.create({
      model: "openai/gpt-oss-20b",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: mensaje },
      ],
      temperature: 0.3,
      max_tokens: 500,
    });

    const respuestaTexto = completion.choices[0]?.message?.content || "No pude generar una respuesta.";

    // 4. Guardar ambos mensajes (pregunta y respuesta) en la tabla 'mensajes_chat' de Supabase
    const registrosAInsertar = [
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "user",
        mensaje: mensaje.trim(),
      },
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "bot",
        mensaje: respuestaTexto,
      },
    ];

    const { error: errorInsert } = await supabase
      .from("mensajes_chat")
      .insert(registrosAInsertar);

    if (errorInsert) {
      console.error("Error guardando el historial en Supabase:", errorInsert.message);
      // No frenamos la respuesta al cliente aunque falle el guardado en BD
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido,
    });
  } catch (error) {
    console.error("Error en Groq Chat Banda Municipal:", error);
    return res.status(500).json({
      message: "Error al procesar la respuesta",
      error: error.message,
    });
  }
};

// Endpoint extra para recuperar la conversacion si el usuario vuelve a abrir la app
export const obtenerHistorialBanda = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data: historial, error } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje, created_at")
      .eq("sesion_id", sesionId)
      .order("created_at", { ascending: true });

    if (error) {
      return res.status(500).json({ message: "Error al consultar historial", error: error.message });
    }

    return res.status(200).json({ historial: historial || [] });
  } catch (error) {
    return res.status(500).json({ message: "Error interno", error: error.message });
  }
};