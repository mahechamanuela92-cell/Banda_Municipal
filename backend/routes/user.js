import express from 'express';
import {obtenerUsuarios } from '../controllers/user.js';
import { getUsuarioPorId } from '../controllers/user.js';
import { updateUsuario } from '../controllers/user.js';
import { Deleteusuario } from '../controllers/user.js';



const router = express.Router();
//ruta para obtener usuarios
router.get('/', obtenerUsuarios);

//ruta para obtener un usuario por su id
router.get('/:id', getUsuarioPorId);

//ruta para actualizar un usuario
router.put('/actualizar/:id', updateUsuario);

//ruta para eliminar un usuario
router.delete('/eliminar/:id', Deleteusuario);




export default router;
