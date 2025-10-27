import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../auth.service';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';


@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './login.component.html'
})


export class LoginComponent {

  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  registered = signal(false);

  loading = signal(false);
  error = signal<string | null>(null);

  constructor() {
    this.route.queryParamMap.subscribe(q => {
      const ok = q.get('registered') === '1';
      this.registered.set(ok);
  
      if (ok) {
        this.router.navigate([], {
          queryParams: { registered: null },
          queryParamsHandling: 'merge',
          replaceUrl: true
        });
      }
    });
  }

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
  });

  get email() { return this.form.get('email')!; }
  get password() { return this.form.get('password')!; }

  async submit() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set(null); 
    try {
      await this.auth.login(this.email.value!, this.password.value!);
      const role = this.auth.getRoleFromToken();
      const target =
        role === 'ADMIN'      ? '/dash-admin'      :
        role === 'MODERADOR'  ? '/dash-mod'  :
        role === 'LOGISTICA'  ? '/dash-logistic'  :
                                 '/dash-comun'; 

      await this.router.navigate([target]); 
    } catch (e: any) {
      this.error.set(e?.message || 'Error al iniciar sesión');
    } finally {
      this.loading.set(false);
    }
  }
}
