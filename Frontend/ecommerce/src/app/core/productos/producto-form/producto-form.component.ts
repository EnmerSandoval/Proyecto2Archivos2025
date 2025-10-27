import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink, RouterLinkActive } from '@angular/router';
import { ProductoService } from '../productos.service';
import { Categoria, Producto } from '../productos.model';

@Component({
  selector: 'app-producto-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, RouterLinkActive],
  templateUrl: './producto-form.component.html',
  styleUrls: ['./producto-form.component.scss']
})
export class ProductoFormComponent {
  private fb = inject(FormBuilder);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private service = inject(ProductoService);

  id = signal<number | null>(null);
  categorias = signal<Categoria[]>([]);
  loading = signal(false);
  error = signal<string | null>(null);
  modoEditar = signal(false);

  form = this.fb.group({
    nombre: ['', [Validators.required, Validators.maxLength(160)]],
    descripcion: ['', [Validators.required]],
    imagenUrl: [''],
    precio: [null as number | null, [Validators.required, Validators.min(0.01)]],
    stock: [null as number | null, [Validators.required, Validators.min(0)]],
    condicion: ['nuevo', [Validators.required]],
    idCategoria: [null as number | null, [Validators.required]],
  });

  ngOnInit() {
    this.loading.set(true);
    this.service.getCategorias().subscribe({ next: (cats) => this.categorias.set(cats) });

    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam) {
      this.modoEditar.set(true);
      const id = Number(idParam);
      this.id.set(id);
      this.service.obtenerProducto(id).subscribe({
        next: (p) => {
          this.form.patchValue({
            nombre: p.nombre,
            descripcion: p.descripcion,
            imagenUrl: p.imagenUrl ?? '',
            precio: p.precio,
            stock: p.stock,
            condicion: p.condicion,
            idCategoria: p.idCategoria
          });
          this.loading.set(false);
        },
        error: (e) => {
          this.error.set(e?.error?.message || 'No se pudo cargar el producto.');
          this.loading.set(false);
        }
      });
    } else {
      this.loading.set(false);
    }
  }

  submit() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.loading.set(true);
    const body = this.form.getRawValue();
  
    const ok = (msg: string) =>
      this.router.navigate(['/mis-productos'], { state: { flash: msg } });
  
    if (this.modoEditar()) {
      this.service.actualizarProducto(this.id()!, body as any).subscribe({
        next: () => ok('Producto actualizado'),
        error: (e) => { this.error.set(e?.error?.message || 'No se pudo actualizar.'); this.loading.set(false); }
      });
    } else {
      this.service.crearProducto(body as any).subscribe({
        next: () => ok('Producto publicado'),
        error: (e) => { this.error.set(e?.error?.message || 'No se pudo crear.'); this.loading.set(false); }
      });
    }
  }
  
  onFile(ev: Event) {
    const input = ev.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    this.loading.set(true);
    this.service.uploadImagen(file).subscribe({
      next: (res) => {
        this.form.patchValue({ imagenUrl: res.url });
        this.loading.set(false);
      },
      error: (e) => {
        this.error.set(e?.error?.error || 'No se pudo subir la imagen.');
        this.loading.set(false);
      }
    });
  }
  

}
