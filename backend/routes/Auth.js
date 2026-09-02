import express from "express";
import { registro, login, verificarCuenta } from "../controllers/Auth.js";
import { olvidarPassword, verifyCode } from "../controllers/recuperar.js";

const router = express.Router();

//rutas de autenticacion 
router.post("/register", registro);
router.post("/login", login);
router.post ('/verify-account', verificarCuenta);

// Rutas de recuperación de contraseña
router.post("/forgot-password", olvidarPassword);
router.post("/reset-password", verifyCode);

export default router;