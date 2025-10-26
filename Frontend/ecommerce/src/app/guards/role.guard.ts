import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, Router } from '@angular/router';
import { AuthService } from '../core/auth/auth.service';

@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private auth: AuthService, private router: Router) {}
  canActivate(route: ActivatedRouteSnapshot): boolean {
    const expected: string[] = route.data['roles'] || [];
    const role = this.auth.getRoleFromToken();
    if (!role || (expected.length && !expected.includes(role))) {
      this.router.navigate(['/login']);
      return false;
    }
    return true;
  }
}
