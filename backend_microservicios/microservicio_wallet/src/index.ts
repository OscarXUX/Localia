import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = 3001;

// Middlewares obligatorios
app.use(cors());
app.use(express.json());

// Base de datos simulada de la Billetera
interface IWalletDB {
  balance: number;
  coppelPoints: number;
  totalSocialImpact: number;
  history: string[];
}

let walletDB: IWalletDB = {
  balance: 2500.0,
  coppelPoints: 450,
  totalSocialImpact: 1250.0,
  history: [
    'Carga inicial Coppel Pay: +$2500.00',
    'Bono de bienvenida Ola México: +$100.00',
  ],
};

// Endpoint principal para consultar el saldo
app.get('/api/v1/wallet', (_req: Request, res: Response) => {
  try {
    res.status(200).json({
      status: 'success',
      data: walletDB,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Error al obtener wallet' });
  }
});

// Encendido del motor
app.listen(PORT, () => {
  console.log(`🚀 Microservicio de Wallet corriendo en http://localhost:${PORT}/api/v1/wallet`);
});