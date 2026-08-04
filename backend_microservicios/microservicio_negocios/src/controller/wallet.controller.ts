import { Request, Response } from 'express';

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

export const getWalletSaldo = (_req: Request, res: Response) => {
  try {
    res.status(200).json({
      status: 'success',
      data: walletDB,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Error al consultar el saldo de la wallet' });
  }
};

export const pagarConWallet = (req: Request, res: Response) => {
  try {
    const { amount, businessName } = req.body as { amount?: number; businessName?: string };

    if (typeof amount !== 'number' || amount <= 0 || !businessName) {
      res.status(400).json({
        status: 'error',
        message: 'Faltan campos obligatorios: amount y businessName',
      });
      return;
    }

    if (walletDB.balance < amount) {
      res.status(400).json({
        status: 'error',
        message: 'Saldo insuficiente en Coppel Pay',
      });
      return;
    }

    walletDB.balance -= amount;
    walletDB.totalSocialImpact += amount;
    walletDB.coppelPoints += Math.floor(amount * 0.1);
    walletDB.history.unshift(`Pago en ${businessName}: -$${amount.toFixed(2)}`);

    res.status(200).json({
      status: 'success',
      message: 'Transacción procesada correctamente',
      data: walletDB,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Error al procesar la transacción' });
  }
};
