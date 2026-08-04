import { Router } from 'express';
import negociosRoutes from './negocios.routes';
const router = Router();
// El prefijo global de tus endpoints
router.use('/api/v1/negocios', negociosRoutes);
export default router;