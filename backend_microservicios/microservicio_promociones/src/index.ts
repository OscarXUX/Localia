import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

// Base de datos simulada de cupones ligados a negocios
let promocionesDB: any[] = [
    {
        id: 'promo_123',
        businessId: '1', // Este ID liga la promo al negocio
        negocio: 'Cenaduría Doña Mary',
        titulo: '2x1 en Enchiladas',
        descuento: '50%',
        descripcion: 'Válido solo los martes presentando tu app Localia.',
        expiracion: '2026-08-31'
    }
];

// ENDPOINT 1: Descargar todas las promociones activas
app.get('/api/v1/promociones', (req: Request, res: Response) => {
    res.status(200).json({
        status: 'success',
        data: promocionesDB
    });
});

// ENDPOINT 2: Crear una nueva promoción desde el panel Admin
app.post('/api/v1/promociones', (req: Request, res: Response) => {
    const nuevaPromo = {
        id: 'promo_' + Date.now(),
        businessId: req.body.businessId,
        negocio: req.body.negocio,
        titulo: req.body.titulo,
        descuento: req.body.descuento,
        descripcion: req.body.descripcion,
        expiracion: req.body.expiracion
    };
    
    // Guardamos la promo en memoria
    promocionesDB.push(nuevaPromo);

    // 🔥 CONSOLA VISUAL: Imprimimos la alerta en la terminal
    console.log(`\n======================================================`);
    console.log(` 🎟️ NUEVO CUPÓN PUBLICADO EN EL ECOSISTEMA LOCALIA `);
    console.log(`======================================================`);
    console.log(` 🏢 Local        : ${nuevaPromo.negocio}`);
    console.log(` 🎁 Promoción    : ${nuevaPromo.titulo}`);
    console.log(` ✂️ Descuento    : ${nuevaPromo.descuento}`);
    console.log(` 💬 Condiciones  : ${nuevaPromo.descripcion}`);
    console.log(` ⏳ Válido hasta : ${nuevaPromo.expiracion}`);
    console.log(`======================================================\n`);

    res.status(201).json({
        status: 'success',
        data: nuevaPromo
    });
});

const PORT = 3004;
app.listen(PORT, () => {
    console.log(`🎟️ Microservicio de Promociones corriendo en http://localhost:${PORT}`);
});