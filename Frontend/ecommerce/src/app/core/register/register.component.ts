import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ReactiveFormsModule, FormBuilder, Validators, FormGroup,
  AbstractControl, ValidationErrors
} from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../auth/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule], // <- IMPORTANTE
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  loading = false;
  error: string | null = null;

  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);

  form: FormGroup = this.fb.group({
    nombre: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    confirm: ['', [Validators.required]],
  }, { validators: [samePasswordValidator] });

  get nombre() { return this.form.get('nombre')!; }
  get email() { return this.form.get('email')!; }
  get password() { return this.form.get('password')!; }
  get confirm() { return this.form.get('confirm')!; }

  submit() {
    if (this.form.invalid) return;
    this.loading = true;
    this.error = null;
    const { nombre, email, password } = this.form.value;

    this.auth.register({ nombre: nombre!, email: email!, password: password! })
      .subscribe({
        next: () => {
          this.loading = false;
          this.router.navigate(['/login'], { queryParams: { registered: 1 } });
        },
        error: (e) => {
          this.loading = false;
          this.error = e?.status === 409 ? 'El correo ya está en uso.' :
                    e?.error?.message || 'No se pudo registrar.';
        }
      });
  }
}

export function samePasswordValidator(control: AbstractControl): ValidationErrors | null {
  const p = control.get('password')?.value;
  const c = control.get('confirm')?.value;
  return p && c && p !== c ? { notSame: true } : null;
}
