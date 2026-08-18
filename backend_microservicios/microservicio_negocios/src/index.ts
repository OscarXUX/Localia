import express from 'express';
import cors from 'cors';
import path from 'path';
import apiRoutes from './routes';

const app = express();
const PORT = 3000;

// Configuración de Middlewares
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

// Registro de las rutas de la API
app.use(apiRoutes);

// Iniciar servidor local
app.listen(PORT, () => {
    console.log(`\n======================================================`);
    console.log(` 🚀 ECOSISTEMA LOCALIA: MICROSERVICIO DE NEGOCIOS `);
    console.log(`======================================================`);
    console.log(` 📡 Estado    : En línea y conectado a SQL Server`);
    console.log(` 🌍 Puerto    : http://localhost:${PORT}`);
    console.log(` 📂 Archivos  : Servidor de imágenes activo (/uploads)`);
    console.log(`======================================================\n`);
});