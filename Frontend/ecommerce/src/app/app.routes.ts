import { Routes } from '@angular/router';

export const routes: Routes = [
    {
        path: '',
        loadComponent: () => 
            import('./core/auth/login/login.component').then(m => m.LoginComponent)
    },
    {path: '***', redirectTo: ''}
];
