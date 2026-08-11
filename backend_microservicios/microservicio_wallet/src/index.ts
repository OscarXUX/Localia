import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

// Base de datos simulada de la bóveda financiera
let walletData = {
    balance: 2500.0,
    coppelPoints: 450,
    totalSocialImpact: 1250.0,
    history: ["Carga inicial Coppel Pay: +$2500.00"]
};

// ENDPOINT 1: Consultar el estado de la cartera (GET)
app.get('/api/v1/wallet', (req: Request, res: Response) => {
    res.status(200).json({
        status: 'success',
        data: walletData
    });
});

// ENDPOINT 2: Procesar un Pago en un Negocio (POST)
app.post('/api/v1/wallet/transaccion', (req: Request, res: Response) => {
    const { amount, businessName } = req.body;

    // Validación de seguridad: Comprobar que haya fondos
    if (walletData.balance >= amount) {
        walletData.balance -= amount;
        walletData.totalSocialImpact += amount;
        walletData.coppelPoints += Math.floor(amount * 0.1); // 10% en puntos
        walletData.history.unshift(`Pago en ${businessName}: -$${amount.toFixed(2)}`);
        
        res.status(200).json({ status: 'success', data: walletData });
    } else {
        res.status(400).json({ status: 'error', message: 'Fondos insuficientes' });
    }
});

// ENDPOINT 3: Recargar saldo (POST)
app.post('/api/v1/wallet/recarga', (req: Request, res: Response) => {
    const { amount } = req.body;
    
    walletData.balance += amount;
    walletData.history.unshift(`Recarga de saldo: +$${amount.toFixed(2)}`);
    
    res.status(200).json({ status: 'success', data: walletData });
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`💳 Microservicio de Wallet corriendo en http://localhost:${PORT}`);
});