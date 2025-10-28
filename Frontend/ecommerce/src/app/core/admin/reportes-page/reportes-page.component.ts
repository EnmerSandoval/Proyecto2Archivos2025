import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';        // para [(ngModel)]
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-reportes-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './reportes-page.component.html'
})
export class ReportesPageComponent implements OnInit {
  private http = inject(HttpClient);

  dias = 7;
  limite = 10;
  loading = signal(false);
  error   = signal<string | null>(null);

  // datos
  porEstado: Array<{ estado:string; total:number }> = [];
  ventasDia: Array<{ dia:string; monto:number; pedidos:number }> = [];
  topVendedores: Array<any> = [];
  topProductos: Array<any> = [];
  topCompradores: Array<any> = [];

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.error.set(null);

    Promise.all([
      this.http.get<Array<{ estado:string; total:number }>>('/api/admin/reportes/pedidos-por-estado').toPromise(),
      this.http.get<Array<{ dia:string; monto:number; pedidos:number }>>('/api/admin/reportes/ventas-ultimos-dias', { params: { dias: this.dias } as any }).toPromise(),
      this.http.get<Array<any>>('/api/admin/reportes/top-vendedores', { params: { dias: this.dias, limite: this.limite } as any }).toPromise(),
      this.http.get<Array<any>>('/api/admin/reportes/top-productos', { params: { dias: this.dias, limite: this.limite } as any }).toPromise(),
      this.http.get<Array<any>>('/api/admin/reportes/top-compradores', { params: { dias: this.dias, limite: this.limite } as any }).toPromise(),
    ]).then(([r1, r2, r3, r4, r5]) => {
      this.porEstado     = r1 ?? [];
      this.ventasDia     = r2 ?? [];
      this.topVendedores = r3 ?? [];
      this.topProductos  = r4 ?? [];
      this.topCompradores= r5 ?? [];
      this.loading.set(false);
    }).catch(e => {
      this.error.set(e?.error?.message || 'No se pudieron cargar los reportes.');
      this.loading.set(false);
    });
  }
}
