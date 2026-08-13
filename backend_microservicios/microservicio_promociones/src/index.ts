import express, { Request, Response } from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

const app = express();
const PORT = 3004;

app.use(cors());
app.use(express.json());

// Base de datos simulada de Promociones
const cuponesDB = [
  {
    id: uuidv4(),
    negocio: "Cenaduría Doña Mary",
    titulo: "2x1 en Enchiladas",
    descripcion: "Válido solo los jueves para turistas registrados en Localia.",
    descuento: "50%",
    expiracion: "2026-08-31"
  },
  {
    id: uuidv4(),
    negocio: "Artesanías El Guayabo",
    titulo: "15% de Descuento",
    descripcion: "En la compra de cualquier jarrito de barro tradicional.",
    descuento: "15%",
    expiracion: "2026-09-15"
  }
];

// Endpoint para consultar las promociones activas
app.get('/api/v1/promociones', (_req: Request, res: Response) => {
  try {
    res.status(200).json({
      status: 'success',
      total: cuponesDB.length,
      data: cuponesDB,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Error al cargar cupones' });
  }
});

app.listen(PORT, () => {
  console.log(`🎟️ Microservicio de Promociones corriendo en http://localhost:${PORT}/api/v1/promociones`);
});