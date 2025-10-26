import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
// import { environment } from '../../environments/environment'; // si ya tienes envs 

type LoginResponse = { token: string; expiresInMs?: number };

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);

  private baseUrl = '/api/auth';

  private tokenKey = 'token';
  private expiresKey = 'token_expires_at';

  isAuth = signal<boolean>(this.hasValidToken());
  remainingMs = computed(() => {
    const exp = this.expiresAt;
    return exp ? Math.max(0, exp - Date.now()) : 0;
  });

  async login(email: string, password: string): Promise<void> {
    const res = await firstValueFrom(
      this.http.post<LoginResponse>(`${this.baseUrl}/login`, { email, password })
    );

    if (!res?.token) throw new Error('Respuesta inválida del servidor');

    localStorage.setItem(this.tokenKey, res.token);

    const expMs = res.expiresInMs ?? this.getExpMsFromJwt(res.token);
    if (expMs) {
      localStorage.setItem(this.expiresKey, String(Date.now() + expMs));
    } else {
      localStorage.removeItem(this.expiresKey); 
    }

    this.isAuth.set(true);
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.expiresKey);
    this.isAuth.set(false);
  }

  get token(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  get expiresAt(): number | null {
    const raw = localStorage.getItem(this.expiresKey);
    return raw ? Number(raw) : null;
  }


  private hasValidToken(): boolean {
    const t = this.token;
    if (!t) return false;

    const expAt = this.expiresAt ?? this.getAbsExpFromJwt(t);
    if (!expAt) return true; 
    return Date.now() < expAt;
  }

  private getExpMsFromJwt(token: string): number | null {
    const abs = this.getAbsExpFromJwt(token);
    return abs ? Math.max(0, abs - Date.now()) : null;
  }

  private getAbsExpFromJwt(token: string): number | null {
    try {
      const payload = JSON.parse(atob(token.split('.')[1] || ''));
      return typeof payload?.exp === 'number' ? payload.exp * 1000 : null;
    } catch {
      return null;
    }
  }

  register(payload: { nombre: string; email: string; password: string }) {
    return this.http.post<void>(`${this.baseUrl}/register`, payload);
  }

  getRoleFromToken(): string | null {
    const t = this.getToken() ?? this.token;
    if (!t) return null;
    try {
      const payload = JSON.parse(atob(t.split('.')[1] || ''));
  
      const raw =
        payload?.role ??
        payload?.roles ??
        payload?.authorities ??
        payload?.rol ??
        payload?.scope ??
        payload?.scopes ??
        payload?.realm_access?.roles;
  
      const normalize = (s: string) => s.replace(/^ROLE_/i, '').toUpperCase();
  
      if (typeof raw === 'string') {
        const parts = raw.split(/[,\s]+/).filter(Boolean);
        const pick =
          parts.find(p => /^(ROLE_)?(ADMIN|COMUN|MODERADOR|LOGISTICA)$/i.test(p)) ??
          parts[0];
        return normalize(pick);
      }
  
      if (Array.isArray(raw)) {
        const fromObj = raw.find((x: any) => x && typeof x.authority === 'string')?.authority;
        const fromStr = raw.find((x: any) => typeof x === 'string');
        const val = (fromObj as string) ?? (fromStr as string);
        return val ? normalize(val) : null;
      }
  
      return null;
    } catch {
      return null;
    }
  }
  

}
