import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { CarritoService, Carrito, CarritoItem } from '../carrito.service';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-carrito-page',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './carrito-page.component.html',
})
export class CarritoPageComponent implements OnInit {
  private carritoSrv = inject(CarritoService);
  private fb = inject(FormBuilder); 

  data = signal<Carrito | null>(null);
  loading = signal(false);
  error = signal<string | null>(null);

  form = this.fb.group({
    direccion: ['', [Validators.required, Validators.minLength(5)]],
  });


  items = computed(() => this.data()?.items ?? []);
  total = computed(() => this.data()?.total ?? 0);

  ngOnInit() { this.cargar(); }

  cargar() {
    this.loading.set(true);
    this.error.set(null);
    this.carritoSrv.ver().subscribe({
      next: (c) => { this.data.set(c); this.loading.set(false); },
      error: (e) => { this.error.set(e?.error?.message || 'No se pudo cargar el carrito.'); this.loading.set(false); }
    });
  }

  inc(it: CarritoItem) { this.actualizar(it, it.cantidad + 1); }
  dec(it: CarritoItem) { if (it.cantidad > 1) this.actualizar(it, it.cantidad - 1); }
  actualizar(it: CarritoItem, cantidad: number) {
    this.loading.set(true);
    this.carritoSrv.actualizar(it.id, cantidad).subscribe({
      next: (c) => { this.data.set(c); this.loading.set(false); },
      error: (e) => { alert(e?.error?.message ?? 'No se pudo actualizar'); this.loading.set(false); }
    });
  }

  eliminar(it: CarritoItem) {
    if (!confirm('¿Quitar este producto?')) return;
    this.loading.set(true);
    this.carritoSrv.eliminar(it.id).subscribe({
      next: (c) => { this.data.set(c); this.loading.set(false); },
      error: (e) => { alert(e?.error?.message ?? 'No se pudo eliminar'); this.loading.set(false); }
    });
  }

  checkout() {
    if (this.form.invalid) return;
    const direccionEnvio = this.form.value.direccion!;
    this.loading.set(true);
    this.carritoSrv.checkout(direccionEnvio).subscribe({
      next: (resp) => {
        this.loading.set(false);
        const loc = resp.headers.get('Location'); 
        alert('Pedido creado');
      },
      error: (e) => { alert(e?.error?.message ?? 'No se pudo completar el pedido'); this.loading.set(false); }
    });
  }
}
