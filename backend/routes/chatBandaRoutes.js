import express from "express";
import { chatBanda, obtenerHistorialBanda } from "../controllers/chatcontroller.js";

const router = express.Router();

router.post("/", chatBanda);
router.get("/historial/:sesionId", obtenerHistorialBanda);

export default router;