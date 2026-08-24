import express from "express";
import { registro, login } from "../controllers/Auth.js";
import { olvidarPassword, verifyCode } from "../controllers/recuperar.js";

const router = express.Router();

router.post("/register", registro);
router.post("/login", login);

// Rutas de recuperación de contraseña
router.post("/forgot-password", olvidarPassword);
router.post("/reset-password", verifyCode);

export default router;