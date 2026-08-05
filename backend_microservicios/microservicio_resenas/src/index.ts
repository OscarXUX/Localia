import express, { Request, Response } from 'express';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

const app = express();
const PORT = 3002;

// Middlewares
app.use(cors());
app.use(express.json());

// Interfaz para las reseñas
interface IReview {

id: string;
businessId: string;
touristName: string;
comment: string;
rating: number;
date: string;
}

// Base de datos simulada en memoria
let reviewsDB: IReview[] = [
{
id: uuidv4(),
businessId: '1', // Simulando un comentario para un negocio con ID 1
touristName: 'Turista Localia',
comment: '¡Me encantó la atención! La Cenaduría tiene platillos riquísimos.',
rating: 5,
date: new Date().toISOString()
}
];

// GET: Leer reseñas de un negocio específico
app.get('/api/v1/resenas/:businessId', (req: Request, res: Response) => {
const { businessId } = req.params;
const filteredReviews = reviewsDB.filter(r => r.businessId === businessId);

res.status(200).json({
status: 'success',

data: filteredReviews
});
});

// POST: Guardar una reseña nueva desde la app
app.post('/api/v1/resenas', (req: Request, res: Response) => {
const { businessId, touristName, comment, rating } = req.body;

if (!businessId || !comment) {
return res.status(400).json({ status: 'error', message: 'Faltan datos obligatorios'
});
}

const newReview: IReview = {
id: uuidv4(),
businessId,
touristName: touristName || 'Turista Anónimo',
comment,
rating: rating || 5,
date: new Date().toISOString()
};

reviewsDB.push(newReview);

res.status(201).json({
status: 'success',
message: 'Reseña guardada correctamente',

data: newReview
});
});

// Encendido del motor
app.listen(PORT, () => {
console.log(` Microservicio de Reseñas corriendo en
http://localhost:${PORT}/api/v1/resenas`);
});