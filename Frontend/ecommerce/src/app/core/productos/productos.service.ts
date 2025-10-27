import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Categoria, Page, Producto } from './productos.model';

export interface ProductoDetalle {
  id: number;
  nombre: string;
  descripcion: string;
  imagenUrl: string | null;
  precio: number;
  stock: number;
  condicion: 'nuevo' | 'usado';
  idCategoria: number;
  estado: 'pendiente' | 'aprobado' | 'rechazado' | 'suspendido';
  creadoEn: string;
  fechaActualizada: string;
}

export interface Resena {
  id: number;
  idProducto: number;      
  idComprador: number;     
  calificacion: number;
  comentario: string | null;
  creadoEn: string;
  compradorNombre: string;
}


@Injectable({ providedIn: 'root' })
export class ProductoService {
  private http = inject(HttpClient);
  private baseUrl = '/api';

  buscarCatalogo(opts: {
    catId?: number | null;
    q?: string | null;
    page?: number;
    size?: number;
  }): Observable<Page<Producto>> {
    let params = new HttpParams()
      .set('page', String(opts.page ?? 0))
      .set('size', String(opts.size ?? 12));

    if (opts.catId != null) params = params.set('catId', String(opts.catId));
    if (opts.q) params = params.set('q', opts.q);

    return this.http.get<Page<Producto>>(`${this.baseUrl}/catalogo`, { params });
  }

  misProductos(params: { q?: string | null; estado?: string | null; page?: number; size?: number }) {
    const httpParams: any = {};
    if (params.q) httpParams.q = params.q;
    if (params.estado) httpParams.estado = params.estado;
    if (params.page !== undefined) httpParams.page = params.page;
    if (params.size !== undefined) httpParams.size = params.size;
    return this.http.get<Page<Producto>>('/api/mis-productos', { params: httpParams });
  }

  getCategorias(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>(`${this.baseUrl}/categorias`);
  }

  crearProducto(body: {
    nombre: string;
    descripcion: string;
    imagenUrl?: string | null;
    precio: number;
    stock: number;
    condicion: 'nuevo'|'usado';
    idCategoria: number;
  }) {
    return this.http.post<void>(`${this.baseUrl}/productos`, body, { observe: 'response' });
  }

  obtenerProducto(id: number) {
    return this.http.get<Producto>(`${this.baseUrl}/productos/${id}`);
  }

  actualizarProducto(id: number, body: {
    nombre: string;
    descripcion: string;
    imagenUrl?: string | null;
    precio: number;
    stock: number;
    condicion: 'nuevo'|'usado';
    idCategoria: number;
  }) {
    return this.http.put<void>(`${this.baseUrl}/productos/${id}`, body, { observe: 'response' });
  }

  uploadImagen(file: File) {
    const fd = new FormData();
    fd.append('file', file);
    return this.http.post<{url: string}>('/api/uploads', fd);
  }

  obtenerProductoPublico(id: number) {
    return this.http.get<ProductoDetalle>(`/api/productos/${id}`);
  }
  
  obtenerResenas(idProducto: number) {
    return this.http.get<Resena[]>(`/api/productos/${idProducto}/resenas`);
  }
  
  crearResena(idProducto: number, body: { calificacion: number; comentario?: string | null }) {
    return this.http.post(`/api/productos/${idProducto}/resenas`, body);
  }

}

