import { Request, Response } from 'express';
import { INegocio } from '../interfaces/negocio.interface';
import { v4 as uuidv4 } from 'uuid';

// Datos estáticos iniciales de Guanajuato para pintar el mapa de inmediato
let negociosDB: INegocio[] = [
 {
    id: "1",
    name: "Artesanías Pénjamo",
    category: "Artesanía",
    description: "Alfarería tradicional y recuerdos locales de la región.",
    location: { latitude: 20.4281, longitude: -101.7229 },
    rating: 4.8,
    isActive: true
 },
 {
    id: "2",
    name: "Cenaduría Abasolo Tradicional",
    category: "Gastronomía",
    description: "Los mejores antojitos y cena típica guanajuatense.",
    location: { latitude: 20.4500, longitude: -101.5200 },
    rating: 4.5,
    isActive: true
 },
 {
    id: "3",
    name: "Tejidos Abasolo",
    category: "Ropa",
    description: "Prendas tejidas a mano por artesanos locales.",
    location: { latitude: 20.4485, longitude: -101.5220 },
    rating: 4.2,
    isActive: true
 }
];
export const getNegocios = (req: Request, res: Response) => {
    try {
        res.status(200).json({
        status: "success",
        data: negociosDB
        });
    } catch (error) {
    res.status(500).json({ status: "error", message: "Error al obtener los negocios" });
    }
    };
export const createNegocio = (req: Request, res: Response) => {
    try {
        const { name, category, description, location, rating, isActive } = req
        const nuevoNegocio: INegocio = {
        id: uuidv4(),
        name,
        category,
        description,
        location,
        rating: rating || 0,
        isActive: isActive !== undefined ? isActive : true
        };

        negociosDB.push(nuevoNegocio);
        res.status(201).json({
        status: "success",
        message: "Negocio creado de manera exitosa",
        data: nuevoNegocio
        });
    } catch (error) {
        res.status(500).json({ status: "error", message: "Error al registrar el deseo negocio" });
    }
    };