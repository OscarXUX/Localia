import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

// Base de datos simulada para las reseñas
let resenasDB: any[] = [
    {
        id: 'resena_1',
        businessId: '1',
        touristName: 'Turista Localia',
        comment: '¡Me encantó la atención! La Cenaduría tiene platillos riquísimos.',
        rating: 5,
        date: new Date().toISOString()
    }
];

// ENDPOINT 1: Obtener reseñas de un negocio específico
app.get('/api/v1/resenas/:businessId', (req: Request, res: Response) => {
    const businessId = req.params.businessId;
    // Filtramos para devolver solo las de ese negocio
    const resenasDelNegocio = resenasDB.filter(r => r.businessId === businessId);
    
    res.status(200).json({
        status: 'success',
        data: resenasDelNegocio
    });
});

// ENDPOINT 2: Crear una nueva reseña desde la app de Flutter
app.post('/api/v1/resenas', (req: Request, res: Response) => {
    const nuevaResena = {
        id: 'resena_' + Date.now(),
        businessId: req.body.businessId,
        touristName: req.body.touristName || 'Turista Anónimo',
        comment: req.body.comment,
        rating: req.body.rating || 5,
        date: new Date().toISOString()
    };
    
    // Guardamos la reseña en memoria (al inicio de la lista)
    resenasDB.unshift(nuevaResena);

    res.status(201).json({
        status: 'success',
        data: nuevaResena
    });
});

const PORT = 3002;
app.listen(PORT, () => {
    console.log(`💬 Microservicio de Reseñas corriendo en http://localhost:${PORT}`);
});
indexadentro.txt
Mostrando indexadentro.txt