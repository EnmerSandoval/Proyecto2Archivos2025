import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Categoria, Page, Producto } from './productos.model';

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
}
