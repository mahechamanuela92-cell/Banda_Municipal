import express from "express";
import {
  getUsuarios,
  getUsuarioPorId,
  updateUsuario,
  deleteUsuario,
} from "../controllers/User.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddlewares.js";

const router = express.Router();

router.get("/", verificarToken, getUsuarios);
router.get("/:id", verificarToken, getUsuarioPorId);
router.put("/:id", verificarToken, verificarAdmin, updateUsuario);
router.delete("/:id", verificarToken, verificarAdmin, deleteUsuario);

export default router;