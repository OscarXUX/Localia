import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { getNegocios, createNegocio, uploadImage, updateNegocio } from '../controller/negocio.controller';

const router = Router();

// CONFIGURACIÓN DE MULTER: Dónde y con qué nombre guardar las fotos
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); 
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// TUS RUTAS NORMALES
router.get('/', getNegocios);
router.post('/', createNegocio);

// 🔥 NUEVA RUTA: Actualizar negocio (El ID viaja en la URL)
router.put('/:id', updateNegocio);

// RUTA DE IMÁGENES: Recibir archivo 
router.post('/upload', upload.single('image'), uploadImage);

export default router;