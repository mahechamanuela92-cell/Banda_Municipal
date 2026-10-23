import express from "express";
import { registro, login, verificarCuenta } from "../controllers/Auth.js";
import { generarCodigoRegistro } from "../controllers/adminControllers.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddlewares.js";
import { olvidarPassword, verifyCode } from "../controllers/recuperar.js";

const router = express.Router();

// Rutas de autenticación públicas
router.post("/register", registro);
router.post("/login", login);
router.post('/verify-account', verificarCuenta);

// Ruta protegida para que el Administrador genere el código de 6 dígitos
router.post("/generar-codigo", verificarToken, verificarAdmin, generarCodigoRegistro);

// Rutas de recuperación de contraseña
router.post("/forgot-password", olvidarPassword);
router.post("/reset-password", verifyCode);

export default router;