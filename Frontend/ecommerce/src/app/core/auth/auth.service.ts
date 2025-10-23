import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';

type LoginResponse = { token: string; expiresInMs: number };

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private baseUrl = 'http://localhost:8080/api/auth';

  isAuth = signal<boolean>(!!localStorage.getItem('token'));

  async login(email: string, password: string): Promise<void> {
    const res = await this.http
      .post<LoginResponse>(`${this.baseUrl}/login`, { email, password })
      .toPromise();

    if (!res?.token) throw new Error('Respuesta inválida del servidor');
    localStorage.setItem('token', res.token);
    this.isAuth.set(true);
  }

  logout() {
    localStorage.removeItem('token');
    this.isAuth.set(false);
  }

  get token(): string | null {
    return localStorage.getItem('token');
  }
}
