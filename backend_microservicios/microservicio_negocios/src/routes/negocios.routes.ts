import { Router } from 'express';
import { getNegocios, createNegocio } from '../controller/negocio.controller';
const router = Router();
router.get('/', getNegocios);
router.post('/', createNegocio);
export default router;
