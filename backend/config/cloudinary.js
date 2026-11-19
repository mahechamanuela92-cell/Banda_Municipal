import 'dotenv/config';
import { v2 as cloudinary } from 'cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';

const { CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET } = process.env;

const faltantes = [
  ['CLOUDINARY_CLOUD_NAME', CLOUDINARY_CLOUD_NAME],
  ['CLOUDINARY_API_KEY', CLOUDINARY_API_KEY],
  ['CLOUDINARY_API_SECRET', CLOUDINARY_API_SECRET],
].filter(([, valor]) => !valor).map(([nombre]) => nombre);

if (faltantes.length > 0) {
  console.error('❌ Faltan variables de Cloudinary:', faltantes.join(', '));
} else {
  console.log('✅ Cloudinary configurado:', CLOUDINARY_CLOUD_NAME);
}

cloudinary.config({
  cloud_name: CLOUDINARY_CLOUD_NAME,
  api_key: CLOUDINARY_API_KEY,
  api_secret: CLOUDINARY_API_SECRET,
  secure: true,
});

const extensionesVideo = new Set([
  '.mp4',
  '.mov',
  '.avi',
  '.mkv',
  '.webm',
  '.3gp',
  '.m4v',
]);

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    const extension = file.originalname
      .slice(file.originalname.lastIndexOf('.'))
      .toLowerCase();
    const esPdf = extension === '.pdf';
    const esVideo =
      req.body?.tipo_archivo === 'video' ||
      file.mimetype?.startsWith('video/') ||
      extensionesVideo.has(extension);

    let resourceType = 'image';
    if (esPdf) {
      resourceType = 'raw';
    } else if (esVideo) {
      resourceType = 'video';
    }

    return {
      folder: 'banda_municipal',
      resource_type: resourceType,
      use_filename: true,
      unique_filename: true,
      type: 'upload',
      format: esPdf ? 'pdf' : undefined,
      access_mode: 'public',
    };
  },
});

const tiposPartituraPermitidos = new Set(['.pdf', '.jpg', '.jpeg', '.png']);

export const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
});

export const uploadPartitura = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, callback) => {
    const extension = file.originalname
      .slice(file.originalname.lastIndexOf('.'))
      .toLowerCase();
    if (!tiposPartituraPermitidos.has(extension)) {
      const error = new Error('Solo se permiten archivos PDF o imágenes JPG, JPEG y PNG');
      error.code = 'UNSUPPORTED_FILE_TYPE';
      return callback(error);
    }
    callback(null, true);
  },
});

export { cloudinary };