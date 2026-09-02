---

# 🎼 BANDA SINFÓNICA MUNICIPAL - SISTEMA DE GESTIÓN

APLICACIÓN MÓVIL PARA GESTIONAR EL INVENTARIO DE INSTRUMENTOS, CATÁLOGO DE PARTITURAS, ASISTENCIA Y EVENTOS DE UNA BANDA SINFÓNICA, DESARROLLADA CON UNA EXCELENTE TECNOLOGÍA

---

## 🛠 Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en un cliente móvil, un servidor backend y una base de datos en la nube, integrando las siguientes tecnologías:

* Node.js + Express (backend)
* Supabase (base de datos)
* Flutter (frontend)
* JWT para el manejo de sesiones

---

## 🚀 Características del Proyecto
* Panel de Control en Tiempo Real: Interfaz intuitiva para monitorear métricas, gestionar registros y controlar permisos de usuarios.
* Procesamiento Multimedia Inteligente: Subida directa de archivos a la nube (Cloudinary) con compresión automática y generación de miniaturas al instante.
* Base de Datos de Alto Rendimiento: Estructura optimizada (MongoDB/Supabase) para búsquedas rápidas, filtros avanzados y sincronización de datos en vivo.
* Autenticación Multi-Nivel: Sistema seguro de inicio de sesión con roles diferenciados (Administrador, Editor, Usuario).
* Entorno Modular y Virtualizado: Diseñado sobre Node.js para facilitar la integración de nuevos módulos y adaptable a contenedores en entornos locales (Hyper-V).
* Diseño Adaptable (Responsive): Totalmente optimizado para funcionar sin problemas en dispositivos móviles, tablets y computadoras de escritorio.

### 🔐 Autenticación y Seguridad

* **Registro e Inicio de Sesión:** Autenticación segura para integrantes y directores mediante tokens (JWT).
* **Control de Acceso Basado en Roles (RBAC):** Vistas y permisos diferenciados para perfiles Músico, Director y Administrador.
* **Protección de Rutas:** Middlewares en el backend para restringir el acceso a endpoints sensibles según el rol.
* **Gestión de Sesión:** Cierre de sesión seguro y expiración automática de credenciales.

---

## ⚙️ Instalación y Configuración
* npm install
* @getbrevo/brevo
* @supabase/ssr
* @supabase/supabase-js
* bcrypt
* cloudinary
* cors
* dotenv
* express
* jsonwebtoken
* multer multer-storage-cloudinary
* nodemailer
* nodemon 

###  Clonar el repositorio

* git clone https://github.com/tu-usuario/banda-sinfonica.git
* Instalación de Node.js
* Instalar npm install
* Instalar librería de Express.js
* Instalar librería de Supabase

---

###  Ejecutar el Servidor

`npm run dev`

---
###  Estructura del proyecto

Banda_Municipal/

└── backend/
    ├── assets/          # Archivos multimedia y recursos locales
    
    ├── config/          # Configuraciones (Base de datos, Cloudinary)
    
    ├── controllers/     # Lógica de negocio de la aplicación
    
    ├── middlewares/     # Validaciones, JWT y subida de archivos
    
    ├── models/          # Modelos y esquemas de datos
    
    ├── routes/          # Definición de rutas y endpoints del API
    
    ├── utils/           # Funciones auxiliares y helpers
    
    ├── .env             # Variables de entorno secretas (Local)
    
    ├── .gitignore       # Exclusiones de control de versiones
    
    ├── index.js         # Punto de entrada y servidor principal
    
    └── package.json     # Dependencias y scripts de Node.js

## 👨‍💻 Autor

* **Manuela Mahecha Paloma**
  * *Tecnóloga en Análisis y Desarrollo de Software (ADSO)*
  *  **Especialidad:** Desarrollo de aplicaciones móviles y web, arquitecturas cliente-servidor e integración de APIs 
* **Danny Camila Cediel Perdomo**
  * *Tecnóloga en Análisis y Desarrollo de Software (ADSO)*
  * **Especialidad:** Desarrollo de aplicaciones móviles y web, arquitecturas cliente-servidor e integración de APIs 

---


