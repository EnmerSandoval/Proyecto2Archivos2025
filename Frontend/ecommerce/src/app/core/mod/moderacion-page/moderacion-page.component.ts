import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormControl } from '@angular/forms';
import { ModeracionApi, ProductoView } from '../moderacion.service';

@Component({
  selector: 'app-moderacion-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './moderacion-page.component.html'
})
export class ModeracionPageComponent implements OnInit {
  private api = inject(ModeracionApi);
  protected readonly Math = Math;

  filtroEstado = new FormControl<string | null>('pendiente'); 
  loading = signal(false);
  error = signal<string | null>(null);

  productos = signal<ProductoView[]>([]);
  page = signal(0);
  size = signal(20);
  totalPages = signal(1);

  ngOnInit() { this.cargar(); }

  cargar(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    this.page.set(page);

    this.api.listar(this.filtroEstado.value || undefined, this.page(), this.size()).subscribe({
      next: (res: any) => {
        const content: ProductoView[] = res.content ?? res; 
        this.productos.set(content);
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

  aprobar(p: ProductoView) {
    if (!confirm(`Aprobar #${p.id} - ${p.nombre}?`)) return;
    this.loading.set(true);
    this.api.aprobar(p.id).subscribe({
      next: () => this.cargar(this.page()),
      error: (e) => { alert(e?.error?.message ?? 'No se pudo aprobar'); this.loading.set(false); }
    });
  }

  rechazar(p: ProductoView) {
    const motivo = prompt(`Motivo de rechazo para #${p.id} - ${p.nombre}:`, p.motivoRechazo || '');
    if (!motivo) return;
    this.loading.set(true);
    this.api.rechazar(p.id, motivo).subscribe({
      next: () => this.cargar(this.page()),
      error: (e) => { alert(e?.error?.message ?? 'No se pudo rechazar'); this.loading.set(false); }
    });
  }
}
