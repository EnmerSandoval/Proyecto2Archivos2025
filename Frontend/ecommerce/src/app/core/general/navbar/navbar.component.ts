import { Component, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../auth/auth.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './navbar.component.html'
})
export class NavbarComponent {
  private auth = inject(AuthService);
  private router = inject(Router);

  isAuth = this.auth.isAuth;

  role = signal<string | null>(this.auth.getRoleFromToken());
  constructor() {
    effect(() => {
      const logged = this.auth.isAuth();
      this.role.set(logged ? this.auth.getRoleFromToken() : null);
    });
  }

  onLogout() {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}
