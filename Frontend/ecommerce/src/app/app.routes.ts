import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },

  {
    path: 'login',
    loadComponent: () =>
      import('./core/auth/login/login.component').then(m => m.LoginComponent),
  },

  {
    path: 'register',
    loadComponent: () =>
      import('./core/register/register.component').then(m => m.RegisterComponent),
  },
  {
    path: 'dash-comun',
    loadComponent: () =>
      import('./core/comun/dash-comun/dash-comun.component').then(m => m.DashComunComponent),
  },
  {
    path: 'dash-admin',
    loadComponent: () =>
      import('./core/admin/dash-admin/dash-admin.component').then(m => m.DashAdminComponent),
  },
  {
    path: 'dash-logistic',
    loadComponent: () =>
      import('./core/logistic/dash-logistic/dash-logistic.component').then(m => m.DashLogisticComponent),
  },
  {
    path: 'dash-mod',
    loadComponent: () =>
      import('./core/mod/dash-mod/dash-mod.component').then(m => m.DashModComponent),
  },
  {
    path: 'catalogo',
    loadComponent:() =>
      import('./core/productos/catalogo/catalogo.component').then(m => m.CatalogoComponent),
  },
  { 
    path: 'mis-productos', 
    loadComponent:() => 
      import('./core/productos/mis-productos/mis-productos.component').then(m => m.MisProductosComponent),
  },
  { path: '**', redirectTo: 'login' },
];
