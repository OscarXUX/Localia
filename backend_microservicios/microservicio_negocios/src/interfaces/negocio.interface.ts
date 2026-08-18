export interface Location {
 latitude: number;
 longitude: number;
}

export interface INegocio {
 id?: string;
 name: string;
 category: string;
 description: string;
 phone?: string;  // 🔥 NUEVO
 image?: string;  // 🔥 NUEVO
 location: Location;
 rating: number;
 isActive: boolean;
}