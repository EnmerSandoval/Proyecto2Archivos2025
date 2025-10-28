import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface PedidoList {
  id: number;
  estado: string;
  montoTotal: number;
  realizadoEn: string; // ISO
}

export interface PedidoItemDet {
  productoId: number;
  nombre: string;
  cantidad: number;
  precioUnitario: number;
  subtotal: number;
  imagenUrl: string | null;
}

export interface PedidoDetalle {
  id: number;
  estado: string;
  montoTotal: number;
  realizadoEn: string; // ISO
  idDireccionEnvio: number | null;
  items: PedidoItemDet[];
}

export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

@Injectable({ providedIn: 'root' })
export class PedidosService {
  private http = inject(HttpClient);
  private base = '/api/pedidos';

  listar(page = 0, size = 12) {
    return this.http.get<Page<PedidoList>>(`${this.base}?page=${page}&size=${size}`);
  }
  detalle(id: number) {
    return this.http.get<PedidoDetalle>(`${this.base}/${id}`);
  }
}
