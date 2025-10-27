import { Component, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { ProductoService } from '../productos.service';
import { Page, Producto } from '../productos.model';
import { ProductoCardComponent } from '../producto-card/producto-card.component';

@Component({
  selector: 'app-mis-productos',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ProductoCardComponent],
  templateUrl: './mis-productos.component.html',
  styleUrl: './mis-productos.component.scss'
})
export class MisProductosComponent {
  private fb = inject(FormBuilder);
  private productosServ = inject(ProductoService);

  data = signal<Page<Producto> | null>(null);
  loading = signal(false);
  error = signal<string | null>(null);

  size = 12;

  form = this.fb.group({
    q: this.fb.control<string>(''),
    estado: this.fb.control<string | null>(null), 
  });

  page = computed(() => this.data()?.number ?? 0);
  totalPages = computed(() => this.data()?.totalPages ?? 0);
  items = computed(() => this.data()?.content ?? []);

  ngOnInit(): void {
    this.load(0);
  }

  load(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    const { q, estado } = this.form.value;

    this.productosServ.misProductos({
      q: q && q.trim() ? q.trim() : null,
      estado: estado ?? null,
      page,
      size: this.size,
    }).subscribe({
      next: (res) => { this.data.set(res); this.loading.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudo cargar.'); this.loading.set(false); }
    });
  }

  submit() { this.load(0); }
  prev()   { if (this.page() > 0) this.load(this.page() - 1); }
  next()   { if (this.page() + 1 < this.totalPages()) this.load(this.page() + 1); }
}
