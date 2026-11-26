import express from "express";
import {
  guardarResultadoMemoria,
  obtenerRankingMemoria,
} from "../controllers/rankingMemoriaController.js";

const router = express.Router();

router.get("/", obtenerRankingMemoria);
router.post("/", guardarResultadoMemoria);

export default router;