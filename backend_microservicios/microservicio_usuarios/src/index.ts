import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

// Base de datos simulada en memoria con múltiples roles
let usuariosDB: Record<string, any> = {
    'premium': {
        name: 'Oscar Manuel Granados Gonzalez',
        email: 'oscar.g@localia.app',
        accountType: 'Turista Premium',
        role: 'admin', // Este rol le da acceso al panel de negocios
        location: 'Abasolo, Gto',
        membersSince: '2026-05-10',
        preferences: ['Boxeo', 'Mecánica Automotriz', 'Gastronomía']
    },
    'basico': {
        name: 'Turista Invitado',
        email: 'invitado@localia.app',
        accountType: 'Turista Básico',
        role: 'user', // Rol restringido
        location: 'Guanajuato',
        membersSince: '2026-08-11',
        preferences: ['Turismo General']
    }
};

let usuarioActual = usuariosDB['premium'];

// ENDPOINT 1: Consultar o cambiar de perfil
app.get('/api/v1/usuarios/perfil', (req: Request, res: Response) => {
    const tipo = req.query.tipo as string;
    
    // Si la app pide un tipo específico que existe, lo cambiamos en sesión
    if (tipo && usuariosDB[tipo]) {
        usuarioActual = usuariosDB[tipo];
    }

    res.status(200).json({
        status: 'success',
        data: usuarioActual
    });
});

// ENDPOINT 2: Crear una nueva cuenta desde el formulario de la app
app.post('/api/v1/usuarios/registro', (req: Request, res: Response) => {
    const nuevoUsuario = req.body;
    
    // Creamos un ID único temporal
    const idUnico = 'user_' + Date.now();
    
    // Lo guardamos en nuestra base de datos simulada
    usuariosDB[idUnico] = {
        name: nuevoUsuario.name,
        email: nuevoUsuario.email,
        accountType: 'Nuevo Turista',
        role: 'user', // Por seguridad, los nuevos nacen como usuarios normales
        location: 'Guanajuato',
        membersSince: new Date().toISOString().split('T')[0],
        preferences: ['Explorador']
    };
    
    // Iniciamos sesión automáticamente con la nueva cuenta
    usuarioActual = usuariosDB[idUnico];

    res.status(201).json({
        status: 'success',
        data: usuarioActual
    });
});

const PORT = 3003;
app.listen(PORT, () => {
    console.log(`🚀 Microservicio de Usuarios corriendo en http://localhost:${PORT}`);
});