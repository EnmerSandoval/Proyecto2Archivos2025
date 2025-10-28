import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';          // *ngIf, *ngFor
import { FormsModule } from '@angular/forms';            // [(ngModel)]
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

type Rol = 'moderador' | 'logistica';

@Component({
  selector: 'app-admin-page',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './admin-page.component.html'
})
export class AdminPageComponent implements OnInit {
  private http = inject(HttpClient);
  private fb   = inject(FormBuilder);

  // para usar Math en el template: {{ Math.max(...) }}
  Math = Math;

  loading = signal(false);
  error   = signal<string | null>(null);

  rolFiltro: Rol = 'moderador';
  usuarios = signal<Array<{ id:number; nombre:string; email:string; rol:string }>>([]);
  page = signal(0);
  size = signal(20);
  totalPages = signal(1);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    rol:   ['moderador' as Rol, Validators.required],
  });

  ngOnInit() { this.cargar(); }

  cargar(page = 0) {
    this.loading.set(true);
    this.error.set(null);
    this.http.get<any>('/api/admin/usuarios', { params: { rol: this.rolFiltro, page, size: this.size() } })
      .subscribe({
        next: (res) => {
          this.usuarios.set(res?.content ?? res ?? []);
          this.totalPages.set(res?.totalPages ?? 1);
          this.page.set(page);
          this.loading.set(false);
        },
        error: (e) => {
          this.error.set(e?.error?.message || 'No se pudo cargar usuarios.');
          this.loading.set(false);
        }
      });
  }

  paginar(delta:number) {
    const next = Math.min(Math.max(this.page() + delta, 0), Math.max(this.totalPages()-1, 0));
    if (next !== this.page()) this.cargar(next);
  }

  abrirModal()  { (document.getElementById('modalRol') as HTMLDialogElement)?.showModal(); }
  cerrarModal() { (document.getElementById('modalRol') as HTMLDialogElement)?.close(); }

  asignar() {
    if (this.form.invalid) return;
    const { email, rol } = this.form.value as { email: string; rol: Rol };
    this.loading.set(true);
    this.http.post<void>('/api/admin/usuarios/asignar-rol', { email: email.trim(), rol })
      .subscribe({
        next: () => { this.cerrarModal(); this.cargar(this.page()); },
        error: (e) => { alert(e?.error?.message || 'No se pudo asignar el rol'); this.loading.set(false); }
      });
  }
}
