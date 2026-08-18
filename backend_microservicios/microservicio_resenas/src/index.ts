import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = 3002;

// Configuración de Middlewares
app.use(cors());
app.use(express.json());

// Base de datos simulada en memoria para las reseñas
const resenasDB: any[] = [];

// 🔥 ENDPOINT PRINCIPAL: Recibir y procesar nuevas reseñas
app.post('/api/v1/resenas', (req: Request, res: Response): any => {
    try {
        const { businessId, touristName, comment, rating } = req.body;

        if (!businessId || !comment) {
            return res.status(400).json({ status: "error", message: "Faltan datos obligatorios" });
        }

        // 1. Creamos el objeto de la reseña
        const nuevaResena = {
            id: Date.now().toString(),
            businessId,
            touristName: touristName || "Turista Anónimo",
            comment,
            rating: rating || 5,
            fecha: new Date().toISOString()
        };

        // 2. Lo guardamos en nuestra base de datos simulada
        resenasDB.push(nuevaResena);

        // 3. 🔥 CONSOLA VISUAL: Imprimimos la alerta en tu terminal (Punto 3)
        console.log(`\n======================================================`);
        console.log(` 🌟 NUEVA RESEÑA RECIBIDA EN EL ECOSISTEMA LOCALIA 🌟 `);
        console.log(`======================================================`);
        console.log(` 🏢 ID del Local : ${businessId}`);
        console.log(` 👤 Turista      : ${nuevaResena.touristName}`);
        console.log(` ⭐ Calificación : ${nuevaResena.rating} Estrellas`);
        console.log(` 💬 Mensaje      : "${nuevaResena.comment}"`);
        console.log(`======================================================\n`);

        // 4. Le avisamos a Flutter que todo salió perfecto
        return res.status(201).json({
            status: 'success',
            message: 'Reseña guardada y procesada exitosamente',
            data: nuevaResena
        });

    } catch (error) {
        console.error("❌ Error al procesar la reseña:", error);
        return res.status(500).json({ status: "error", message: "Error interno del servidor" });
    }
});

// Endpoint de prueba para ver todas las reseñas
app.get('/api/v1/resenas', (req: Request, res: Response) => {
    res.status(200).json({ status: 'success', data: resenasDB });
});

// Iniciar servidor local
app.listen(PORT, () => {
    console.log(`📝 Microservicio de Reseñas de Localia activo en: http://localhost:${PORT}`);
    console.log(`Esperando comentarios de los turistas...`);
});