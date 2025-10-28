import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class LogisticaApi {
  constructor(private http: HttpClient) {}

  listar(estado?: string, page = 0, size = 20) {
    const params: any = { page, size };
    if (estado) params.estado = estado;
    return this.http.get<any>('/api/logistica/pedidos', { params });
  }

  enRuta(id: number) {
    return this.http.patch<void>(`/api/logistica/pedidos/${id}/en-ruta`, {});
  }

  entregado(id: number) {
    return this.http.patch<void>(`/api/logistica/pedidos/${id}/entregado`, {});
  }
}
