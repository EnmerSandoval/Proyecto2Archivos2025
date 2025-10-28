import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { PedidosService, PedidoList, Page } from '../pedidos/pedidos.component';

@Component({
  selector: 'app-pedidos-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './pedidos-list.component.html',
})
export class PedidosListComponent implements OnInit {
  private srv = inject(PedidosService);

  data = signal<Page<PedidoList> | null>(null);
  loading = signal(false);
  error = signal<string | null>(null);
  size = 12;

  page = computed(() => this.data()?.number ?? 0);
  totalPages = computed(() => this.data()?.totalPages ?? 0);
  items = computed(() => this.data()?.content ?? []);

  ngOnInit() { this.load(0); }

  load(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    this.srv.listar(page, this.size).subscribe({
      next: (res) => { this.data.set(res); this.loading.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudo cargar.'); this.loading.set(false); }
    });
  }

  prev() { if (this.page() > 0) this.load(this.page() - 1); }
  next() { if (this.page() + 1 < this.totalPages()) this.load(this.page() + 1); }
}
