import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormControl } from '@angular/forms';
import { LogisticaApi } from '../logistica.service';

type PedidoView = {
  id: number;
  idComprador: number;
  estado: string;
  creadoEn: string;
  fechaPrometidaEntrega: string | null;
  fechaEntrega: string | null;
  direccionEnvio: string;
  montoTotal: number;
};

@Component({
  selector: 'app-logistica-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './logistica-page.component.html'
})
export class LogisticaPageComponent implements OnInit {
  private api = inject(LogisticaApi);
  protected readonly Math = Math;

  filtroEstado = new FormControl<string | null>('creado');
  loading = signal(false);
  error = signal<string | null>(null);
  pedidos = signal<PedidoView[]>([]);
  page = signal(0);
  size = signal(20);
  totalPages = signal(0);

  ngOnInit() {
    this.cargar();
  }

  cargar(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    this.page.set(page);

    this.api.listar(this.filtroEstado.value || undefined, this.page(), this.size()).subscribe({
      next: (res: any) => {
        const content: PedidoView[] = res.content ?? res;
        this.pedidos.set(content);
        this.totalPages.set(res.totalPages ?? 1);
        this.loading.set(false);
      },
      error: (e) => {
        this.error.set(e?.error?.message || 'No se pudo cargar la lista.');
        this.loading.set(false);
      }
    });
  }

  paginar(delta: number) {
    const next = Math.min(Math.max(this.page() + delta, 0), Math.max(this.totalPages() - 1, 0));
    if (next !== this.page()) this.cargar(next);
  }

  marcarEnRuta(p: PedidoView) {
    this.loading.set(true);
    this.api.enRuta(p.id).subscribe({
      next: () => this.cargar(this.page()),
      error: (e) => { alert(e?.error?.message ?? 'No se pudo cambiar a en_ruta'); this.loading.set(false); }
    });
  }

  marcarEntregado(p: PedidoView) {
    this.loading.set(true);
    this.api.entregado(p.id).subscribe({
      next: () => this.cargar(this.page()),
      error: (e) => { alert(e?.error?.message ?? 'No se pudo marcar entregado'); this.loading.set(false); }
    });
  }
}
