import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { ProductoService } from '../productos.service';
import { Categoria, Page, Producto } from '../productos.model';
import { ProductoCardComponent } from '../producto-card/producto-card.component';
import { CarritoService } from '../../carrito/carrito.service';

 

@Component({
  selector: 'app-catalogo',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ProductoCardComponent],
  templateUrl: './catalogo.component.html'
})
export class CatalogoComponent implements OnInit {
  private fb = inject(FormBuilder);
  private productosSrv = inject(ProductoService);
  private carrito = inject(CarritoService);
  

  categorias = signal<Categoria[]>([]);
  data = signal<Page<Producto> | null>(null);
  loading = signal(false);
  error = signal<string | null>(null);

  size = 12;

  form = this.fb.group({
    catId: this.fb.control<number | null>(null),
    q: this.fb.control<string>(''),
  });

  page = computed(() => this.data()?.number ?? 0);
  totalPages = computed(() => this.data()?.totalPages ?? 0);
  items = computed(() => this.data()?.content ?? []);

  ngOnInit(): void {
    this.productosSrv.getCategorias().subscribe({
      next: (res) => this.categorias.set(res),
      error: () => this.categorias.set([]),
    });
    this.load(0);
  }

  load(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    const { catId, q } = this.form.value;
    this.productosSrv.buscarCatalogo({
      catId: catId ?? null,
      q: q && q.trim() ? q.trim() : null,
      page,
      size: this.size,
    }).subscribe({
      next: (res) => { this.data.set(res); this.loading.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudo cargar.'); this.loading.set(false); }
    });
  }

  agregarAlCarrito(p: Producto) {
    this.carrito.agregar(p.id, 1).subscribe({
      next: () => alert('Agregado al carrito'),
      error: e => alert(e?.error?.message ?? 'No se pudo agregar')
    });
  }

  submit() { this.load(0); }
  prev()   { if ((this.page() ?? 0) > 0) this.load(this.page() - 1); }
  next()   { if ((this.page() ?? 0) + 1 < this.totalPages()) this.load(this.page() + 1); }
}
