import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = 3003;

app.use(cors());
app.use(express.json());

// Base de datos simulada del Usuario
const userProfile = {
  id: 'usr_98765',
  name: 'Óscar Granados',
  email: 'oscar.g@localia.app',
  accountType: 'Turista Premium',
  memberSince: '2026-05-10',
  preferences: ['Gastronomía', 'Artesanías', 'Aventura']
};

// Endpoint para consultar el perfil
app.get('/api/v1/usuarios/perfil', (_req: Request, res: Response) => {
  try {
    res.status(200).json({
      status: 'success',
      data: userProfile,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'No se pudo cargar el perfil' });
  }
});

app.listen(PORT, () => {
  console.log(`👤 Microservicio de Usuarios corriendo en http://localhost:${PORT}/api/v1/usuarios/perfil`);
});
