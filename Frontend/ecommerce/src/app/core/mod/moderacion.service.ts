import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface ProductoView {
  id: number;
  nombre: string;
  precio: number;
  estado: string;
  motivoRechazo?: string | null;
  revisadoEn?: string | null;
  revisadoPorId?: number | null;
  vendedorId?: number | null;
}

@Injectable({ providedIn: 'root' })
export class ModeracionApi {
  constructor(private http: HttpClient) {}

  listar(estado?: string, page = 0, size = 20) {
    const params: any = { page, size };
    if (estado) params.estado = estado; 
    return this.http.get<any>('/api/moderacion/productos', { params });
  }

  aprobar(id: number) {
    return this.http.patch<void>(`/api/moderacion/productos/${id}/aprobar`, {});
  }

  rechazar(id: number, motivo: string) {
    return this.http.patch<void>(`/api/moderacion/productos/${id}/rechazar`, { motivo });
  }
}
