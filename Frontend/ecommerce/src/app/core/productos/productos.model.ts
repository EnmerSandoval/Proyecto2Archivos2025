export interface Categoria {
    id: number;
    nombre: string;
}

export type CondicionProducto = 'nuevo' | 'usado';

export interface Producto {
    id: number;
    nombre: string;
    descripcion: string;
    imagenUrl?: string;     
    precio: number;
    stock: number;
    condicion: CondicionProducto;
    categoria?: Categoria;
    idCategoria?: number;
  }
  
  export interface Page<T> {
    content: T[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number; 
    first: boolean;
    last: boolean;
  }