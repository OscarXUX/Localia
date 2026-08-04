export interface Location {
 latitude: number;
 longitude: number;
}
export interface INegocio {
 id?: string;
 name: string;
 category: string;
 description: string;
 location: Location;
 rating: number;
 isActive: boolean;
}
