import { Router } from 'express';
import { getWalletSaldo, pagarConWallet } from '../controller/wallet.controller';

const router = Router();

router.get('/saldo', getWalletSaldo);
router.post('/pagar', pagarConWallet);

export default router;
