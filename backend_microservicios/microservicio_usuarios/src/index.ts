import express, { Request, Response } from 'express';
import cors from 'cors';
import sql from 'mssql';

const app = express();
app.use(cors());
app.use(express.json());

// CONFIGURACIÓN DE TU SQL SERVER LOCAL
const dbSettings = {
    user: 'sa', // Cambia si usas otro usuario
    password: 'localia123', // Pon aquí tu contraseña real
    server: 'localhost', // Si usas SQLEXPRESS puede ser 'localhost\\SQLEXPRESS'
    database: 'LocaliaDB',
    options: {
        encrypt: false, // Fundamental para bases de datos locales
        trustServerCertificate: true
    }
};

// ENDPOINT: Inicio de sesión validado
app.post('/api/v1/usuarios/login', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;
        
        const pool = await sql.connect(dbSettings);
        const result = await pool.request()
            .input('email', sql.VarChar, email)
            .input('password', sql.VarChar, password)
            // 🔥 Filtramos estrictamente por correo Y contraseña
            .query('SELECT * FROM Usuarios WHERE email = @email AND password = @password');

        if (result.recordset.length > 0) {
            // Si encontró coincidencia, dejamos pasar al usuario
            const user = result.recordset[0];
            
            console.log(`\n======================================================`);
            console.log(` 🔐 INICIO DE SESIÓN AUTORIZADO (SQL SERVER) `);
            console.log(`======================================================`);
            console.log(` 👤 Usuario : ${user.name}`);
            console.log(` 📧 Correo  : ${user.email}`);
            console.log(` 🛡️ Rol     : ${user.role.toUpperCase()}`);
            console.log(`======================================================\n`);

            res.status(200).json({ status: 'success', data: user });
        } else {
            // Si no, le negamos el acceso
            console.log(`\n======================================================`);
            console.log(` ❌ ALERTA: INTENTO DE ACCESO DENEGADO `);
            console.log(`======================================================`);
            console.log(` 📧 Correo intentado : ${email}`);
            console.log(` ⚠️ Razón            : Credenciales inválidas`);
            console.log(`======================================================\n`);

            res.status(401).json({ status: 'error', message: 'Credenciales inválidas' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'error', message: 'Error del servidor' });
    }
});

// ENDPOINT 2: Obtener perfil (Para cambiar de cuenta desde la app)
app.get('/api/v1/usuarios/perfil', async (req: Request, res: Response) => {
    try {
        const tipo = req.query.tipo as string; // 'premium' o 'basico'
        const roleABuscar = tipo === 'premium' ? 'admin' : 'user';

        const pool = await sql.connect(dbSettings);
        const result = await pool.request()
            .input('role', sql.VarChar, roleABuscar)
            .query('SELECT TOP 1 * FROM Usuarios WHERE role = @role');

        if (result.recordset.length > 0) {
            const user = result.recordset[0];

            console.log(`\n======================================================`);
            console.log(` 🔄 CAMBIO DE PERFIL SOLICITADO `);
            console.log(`======================================================`);
            console.log(` 👤 Nuevo Perfil : ${user.name}`);
            console.log(` 🛡️ Nivel        : ${user.role.toUpperCase()}`);
            console.log(`======================================================\n`);

            res.status(200).json({ status: 'success', data: user });
        } else {
            res.status(404).json({ status: 'error', message: 'Usuario no encontrado' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'error', message: 'Fallo en la base de datos' });
    }
});

// ENDPOINT 3: Registro de nueva cuenta (Actualizado)
app.post('/api/v1/usuarios/registro', async (req: Request, res: Response) => {
    try {
        // Ahora sí extraemos el password de la app
        const { name, email, password, role } = req.body; 
        const idUnico = 'user_' + Date.now();
        const fechaActual = new Date().toISOString().split('T')[0];

        const pool = await sql.connect(dbSettings);
        await pool.request()
            .input('id', sql.VarChar, idUnico)
            .input('name', sql.VarChar, name)
            .input('email', sql.VarChar, email)
            .input('password', sql.VarChar, password) // <-- Guardamos la contraseña real
            .input('accountType', sql.VarChar, 'Nuevo Turista')
            .input('role', sql.VarChar, role)
            .input('location', sql.VarChar, 'Guanajuato')
            .input('membersSince', sql.VarChar, fechaActual)
            .query(`INSERT INTO Usuarios (id, name, email, password, accountType, role, location, membersSince) 
                    VALUES (@id, @name, @email, @password, @accountType, @role, @location, @membersSince)`);

        const newUser = await pool.request()
            .input('id', sql.VarChar, idUnico)
            .query('SELECT * FROM Usuarios WHERE id = @id');

        console.log(`\n======================================================`);
        console.log(` 🌟 NUEVO TURISTA REGISTRADO EN SQL SERVER `);
        console.log(`======================================================`);
        console.log(` 👤 Nombre : ${name}`);
        console.log(` 📧 Correo : ${email}`);
        console.log(` 🛡️ Rol    : ${role.toUpperCase()}`);
        console.log(` 📅 Fecha  : ${fechaActual}`);
        console.log(`======================================================\n`);

        res.status(201).json({ status: 'success', data: newUser.recordset[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'error', message: 'Error al registrar en BD' });
    }
});

const PORT = 3003;
app.listen(PORT, () => {
    console.log(`\n======================================================`);
    console.log(` 🚀 ECOSISTEMA LOCALIA: MICROSERVICIO DE USUARIOS `);
    console.log(`======================================================`);
    console.log(` 📡 Estado    : En línea y conectado a SQL Server`);
    console.log(` 🌍 Puerto    : http://localhost:${PORT}`);
    console.log(`======================================================\n`);
});