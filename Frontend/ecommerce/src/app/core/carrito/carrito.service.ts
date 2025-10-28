// src/app/core/carrito/carrito.service.ts
import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface CarritoItem {
  id: number;
  productoId: number;
  nombre: string;
  imagenUrl: string | null;
  cantidad: number;
  precioUnitario: number;
  subtotal: number;
}
export interface Carrito {
  id: number | null;
  items: CarritoItem[];
  total: number;
}

@Injectable({ providedIn: 'root' })
export class CarritoService {
  private http = inject(HttpClient);
  private base = '/api/carrito';

  ver() {
    return this.http.get<Carrito>(this.base);
  }
  agregar(productoId: number, cantidad = 1) {
    return this.http.post<Carrito>(`${this.base}/items`, { productoId, cantidad });
  }
  actualizar(itemId: number, cantidad: number) {
    return this.http.patch<Carrito>(`${this.base}/items/${itemId}`, { cantidad });
  }
  eliminar(itemId: number) {
    return this.http.delete<Carrito>(`${this.base}/items/${itemId}`);
  }
  checkout(direccionEnvio: string) {
    return this.http.post(`${this.base}/checkout`, { direccionEnvio }, { observe: 'response' });
  }
}
