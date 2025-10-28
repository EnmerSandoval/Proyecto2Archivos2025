import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export type Rol = 'moderador' | 'logistica';

@Injectable({ providedIn: 'root' })
export class AdminApi {
  constructor(private http: HttpClient) {}

  usuarios(rol: Rol, page = 0, size = 20) {
    return this.http.get<any>('/api/admin/usuarios', { params: { rol, page, size } });
  }

  asignarRol(email: string, rol: Rol) {
    return this.http.post<void>('/api/admin/usuarios/asignar-rol', { email, rol });
  }

  pedidosPorEstado() {
    return this.http.get<Array<{ estado: string; total: number }>>('/api/admin/reportes/pedidos-por-estado');
  }
  ventasUltimosDias(dias = 7) {
    return this.http.get<Array<{ dia: string; monto: number; pedidos: number }>>('/api/admin/reportes/ventas-ultimos-dias', { params: { dias } });
  }
}
