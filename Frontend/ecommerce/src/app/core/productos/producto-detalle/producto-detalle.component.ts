import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ProductoService, ProductoDetalle, Resena } from '../productos.service';

@Component({
  standalone: true,
  selector: 'app-producto-detalle',
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './producto-detalle.component.html',
})
export class ProductoDetalleComponent {
  private route = inject(ActivatedRoute);
  private service = inject(ProductoService);
  private fb = inject(FormBuilder);

  producto = signal<ProductoDetalle | null>(null);
  resenas  = signal<Resena[]>([]);
  error = signal<string|null>(null);

  cargando = signal(true);          // loading del detalle
  cargandoResenas = signal(false);  // loading de reseñas
  publicando = signal(false);       // loading del POST de reseña

  form = this.fb.group({
    calificacion: [5, [Validators.required, Validators.min(1), Validators.max(5)]],
    comentario: [''],
  });

  avg = computed(() => {
    const rs = this.resenas();
    if (!rs.length) return null;
    const v = rs.reduce((s, r) => s + (r.calificacion ?? 0), 0) / rs.length;
    return Math.round(v * 10) / 10;
  });

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    if (Number.isNaN(id)) {
      this.error.set('ID de producto inválido.');
      this.cargando.set(false);
      return;
    }

    // Cargar detalle (público)
    this.cargando.set(true);
    this.service.obtenerProductoPublico(id).subscribe({
      next: (p) => { this.producto.set(p); this.cargando.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudo cargar el producto.'); this.cargando.set(false); }
    });

    // Cargar reseñas
    this.cargarResenas(id);
  }

  cargarResenas(id: number) {
    this.cargandoResenas.set(true);
    this.service.obtenerResenas(id).subscribe({
      next: (rs) => { this.resenas.set(rs); this.cargandoResenas.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudieron cargar las reseñas.'); this.cargandoResenas.set(false); }
    });
  }

  publicar() {
    if (this.form.invalid || !this.producto()) return;
    const id = this.producto()!.id;
    const { calificacion, comentario } = this.form.getRawValue();
    const cal = Number(calificacion);

    this.publicando.set(true);
    this.service.crearResena(id, {
      calificacion: cal,
      comentario: (comentario || '').trim() || null
    }).subscribe({
      next: () => {
        this.form.reset({ calificacion: 5, comentario: '' });
        this.cargarResenas(id);
        this.publicando.set(false);
        alert('Reseña publicada');
      },
      error: (e) => {
        this.error.set(e?.error?.message || 'No se pudo publicar la reseña.');
        this.publicando.set(false);
      }
    });
  }

  stars(n: number) { return Array.from({ length: n }); }
}
