import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = 3001;

// Configuración de Middlewares
app.use(cors());
app.use(express.json());

// 🔥 BASE DE DATOS EN MEMORIA: Simulando el estado de la cuenta
let walletState = {
    balance: 2500.0,
    coppelPoints: 450,
    totalSocialImpact: 1250.0,
    history: ["Carga inicial: + $2500.00"]
};

// ENDPOINT 1: Obtener los datos al abrir la app
app.get('/api/v1/wallet', (req: Request, res: Response) => {
    res.status(200).json({ status: 'success', data: walletState });
});

// ENDPOINT 2: Recargar Saldo
app.post('/api/v1/wallet/recarga', (req: Request, res: Response): any => {
    const { amount } = req.body;
    
    if (!amount || amount <= 0) {
        return res.status(400).json({ status: "error", message: "Monto inválido" });
    }

    // Sumamos el saldo
    walletState.balance += amount;
    // Registramos en el historial al principio de la lista
    walletState.history.unshift(`Recarga Coppel Pay: + $${amount.toFixed(2)}`);

    // 🔥 CONSOLA VISUAL: Notificación de Recarga
    console.log(`\n======================================================`);
    console.log(` 💳 RECARGA DE BILLETERA COPPEL PAY `);
    console.log(`======================================================`);
    console.log(` 💵 Monto ingresado : + $${amount.toFixed(2)} MXN`);
    console.log(` 🏦 Saldo Actual    : $${walletState.balance.toFixed(2)} MXN`);
    console.log(`======================================================\n`);

    return res.status(200).json({ status: 'success', data: walletState });
});

// ENDPOINT 3: Realizar un pago o transferencia P2P
app.post('/api/v1/wallet/transaccion', (req: Request, res: Response): any => {
    const { amount, businessName } = req.body;
    
    if (!amount || amount <= 0) {
        return res.status(400).json({ status: "error", message: "Monto inválido" });
    }
    
    if (walletState.balance < amount) {
        return res.status(400).json({ status: "error", message: "Fondos insuficientes" });
    }

    // 1. Restamos el saldo
    walletState.balance -= amount;
    // 2. Sumamos al impacto social del estado
    walletState.totalSocialImpact += amount;
    // 3. Otorgamos el 10% en puntos Coppel
    walletState.coppelPoints += Math.floor(amount * 0.1);
    
    // 4. Registramos el movimiento
    const destino = businessName || "Usuario P2P";
    walletState.history.unshift(`Transferencia a ${destino}: - $${amount.toFixed(2)}`);

    // 🔥 CONSOLA VISUAL: Notificación de Transferencia / Pago
    console.log(`\n======================================================`);
    console.log(` 💸 TRANSFERENCIA REALIZADA `);
    console.log(`======================================================`);
    console.log(` 🏢 Destino         : ${destino}`);
    console.log(` 💰 Monto enviado   : - $${amount.toFixed(2)} MXN`);
    console.log(` 🌟 Puntos ganados  : + ${Math.floor(amount * 0.1)} Pts`);
    console.log(` 🏦 Saldo Restante  : $${walletState.balance.toFixed(2)} MXN`);
    console.log(`======================================================\n`);

    return res.status(200).json({ status: 'success', data: walletState });
});

app.listen(PORT, () => {
    console.log(`\n======================================================`);
    console.log(` 🚀 ECOSISTEMA LOCALIA: MICROSERVICIO BILLETERA `);
    console.log(`======================================================`);
    console.log(` 📡 Estado    : En línea (Motor de Pagos)`);
    console.log(` 🌍 Puerto    : http://localhost:${PORT}`);
    console.log(`======================================================\n`);
});