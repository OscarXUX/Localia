import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import sql from 'mssql'; 

// CONFIGURACIÓN DE TU SQL SERVER LOCAL
const dbSettings = {
    user: 'sa', 
    password: 'localia123', 
    server: 'localhost', 
    database: 'LocaliaDB',
    options: {
        encrypt: false, 
        trustServerCertificate: true
    }
};

// ENDPOINT 1: Leer los negocios reales
export const getNegocios = async (req: Request, res: Response): Promise<any> => {
    try {
        const pool = await sql.connect(dbSettings);
        const result = await pool.request().query('SELECT * FROM Negocios');

        return res.status(200).json({
            status: "success",
            data: result.recordset
        });
    } catch (error) {
        console.error("Error en GET /negocios:", error);
        return res.status(500).json({ status: "error", message: "Error al obtener los negocios de SQL Server" });
    }
};

// ENDPOINT 2: Crear un negocio nuevo y guardarlo en SQL
export const createNegocio = async (req: Request, res: Response): Promise<any> => {
    try {
        // 🔥 Ahora extraemos también el ownerId que viaja desde Flutter
        const { name, category, description, phone, image, address, representative, rfc, schedule, priceLevel, ownerId } = req.body;
        const newId = uuidv4();
        
        const finalPhone = phone || "Sin teléfono";
        const finalImage = image || "https://placehold.co/400x200/008F39/FFFFFF/png?text=Nuevo+Local";
        const finalAddress = address || "Guanajuato, México";
        const finalSchedule = schedule || "09:00 - 18:00";
        const finalRating = 5.0; 

        const pool = await sql.connect(dbSettings);
        
        await pool.request()
            .input('id', sql.VarChar, newId)
            .input('ownerId', sql.VarChar, ownerId || '') // 🔥 Guardamos el ID del dueño
            .input('name', sql.VarChar, name)
            .input('category', sql.VarChar, category)
            .input('rating', sql.Float, finalRating)
            .input('priceLevel', sql.Int, priceLevel || 1)
            .input('description', sql.NVarChar, description || '')
            .input('address', sql.VarChar, finalAddress)
            .input('phone', sql.VarChar, finalPhone)
            .input('representative', sql.VarChar, representative || '')
            .input('rfc', sql.VarChar, rfc || '')
            .input('schedule', sql.VarChar, finalSchedule)
            .input('image', sql.NVarChar, finalImage)
            .query(`
                INSERT INTO Negocios 
                (id, ownerId, name, category, rating, priceLevel, description, address, phone, representative, rfc, schedule, image)
                VALUES 
                (@id, @ownerId, @name, @category, @rating, @priceLevel, @description, @address, @phone, @representative, @rfc, @schedule, @image)
            `);

        console.log(`\n======================================================`);
        console.log(` 🏪 NUEVO NEGOCIO GUARDADO EN SQL SERVER `);
        console.log(`======================================================`);
        console.log(` 📌 Nombre     : ${name}`);
        console.log(` 👤 Dueño ID   : ${ownerId || 'Huérfano'}`);
        console.log(` 📍 Ubicación  : ${finalAddress}`);
        console.log(`======================================================\n`);

        return res.status(201).json({
            status: "success",
            message: "Negocio guardado en la base de datos exitosamente",
            data: { id: newId, name, category, ownerId }
        });
    } catch (error) {
        console.error("Error en POST /negocios:", error);
        return res.status(500).json({ status: "error", message: "Error al registrar el nuevo negocio en SQL Server" });
    }
};

// 🔥 NUEVO ENDPOINT 3: Actualizar un negocio existente
export const updateNegocio = async (req: Request, res: Response): Promise<any> => {
    try {
        const { id } = req.params; // Sacamos el ID de la URL
        const { name, category, description, phone, image, address, representative, rfc, schedule, priceLevel } = req.body;

        const pool = await sql.connect(dbSettings);
        
        const result = await pool.request()
            .input('id', sql.VarChar, id)
            .input('name', sql.VarChar, name)
            .input('category', sql.VarChar, category)
            .input('description', sql.NVarChar, description || '')
            .input('phone', sql.VarChar, phone || '')
            .input('image', sql.NVarChar, image || '')
            .input('address', sql.VarChar, address || '')
            .input('representative', sql.VarChar, representative || '')
            .input('rfc', sql.VarChar, rfc || '')
            .input('schedule', sql.VarChar, schedule || '')
            .input('priceLevel', sql.Int, priceLevel || 1)
            .query(`
                UPDATE Negocios 
                SET name = @name, 
                    category = @category, 
                    description = @description, 
                    phone = @phone, 
                    image = @image, 
                    address = @address, 
                    representative = @representative, 
                    rfc = @rfc, 
                    schedule = @schedule, 
                    priceLevel = @priceLevel
                WHERE id = @id
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ status: "error", message: "No se encontró el negocio para actualizar" });
        }

        return res.status(200).json({ status: "success", message: "Negocio actualizado en la base de datos" });
    } catch (error) {
        console.error("Error en PUT /negocios/:id :", error);
        return res.status(500).json({ status: "error", message: "Error al actualizar el negocio" });
    }
};

// ENDPOINT 4: Generar el enlace público de la imagen
export const uploadImage = (req: Request, res: Response): any => {
    try {
        if (!req.file) {
            return res.status(400).json({ status: "error", message: "No se recibió ninguna imagen" });
        }
        
        const imageUrl = `http://localhost:3000/uploads/${req.file.filename}`;
        
        return res.status(200).json({ status: "success", imageUrl: imageUrl });
    } catch (error) {
        console.error("Error al procesar la imagen:", error);
        return res.status(500).json({ status: "error", message: "Error interno al subir la foto" });
    }
};