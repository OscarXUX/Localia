import express from 'express';
import cors from 'cors';

import apiRoutes from './routes';
const app = express();
const PORT = 3000;
// Configuración de Middlewares
app.use(cors());
app.use(express.json());
// Registro de las rutas de la API
app.use(apiRoutes);
// Iniciar servidor local
app.listen(PORT, () => {
 console.log(`🚀 Microservicio de Negocios de Localia activo en: http://localhost:${PORT}`);
});