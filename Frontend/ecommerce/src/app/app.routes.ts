import { Routes } from '@angular/router';
import { RoleGuard } from './guards/role.guard';
import { AuthGuard } from './guards/auth.guard'; 

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
  {
    path: 'comun/productos/nuevo',
    loadComponent: () =>
      import('./core/productos/producto-form/producto-form.component').then(m => m.ProductoFormComponent),
    //canActivate: [AuthGuard, RoleGuard],         
    //data: { roles: ['comun'] },         
  },  
  {
    path: 'comun/productos/editar/:id',
    loadComponent: () =>
      import('./core/productos/producto-form/producto-form.component')
        .then(m => m.ProductoFormComponent),
   // canActivate: [AuthGuard, RoleGuard],
    // data: { roles: ['comun','admin'] },
  },  
  {
    path: 'producto/:id',
    loadComponent:() =>
      import('./core/productos/producto-detalle/producto-detalle.component').then(m => m.ProductoDetalleComponent),
  },
  {
    path: 'carrito',
    loadComponent:() =>
      import('./core/carrito/carrito-page/carrito-page.component').then(m => m.CarritoPageComponent),
  },
  {
    path: 'pedidos',
    loadComponent:() => 
      import ('./core/pedidos/pedidos-list/pedidos-list.component').then(m => m.PedidosListComponent),
  },
  {
    path: 'pedidos/:id',
    loadComponent: ()=>
      import ('./core/pedidos/pedido-detalle/pedido-detalle.component').then(m => m.PedidoDetalleComponent),
  },
  { path: 'logistica', loadComponent: () => import('./core/logistic/logistica-page/logistica-page.component').then(m => m.LogisticaPageComponent) },
  { path: 'moderacion', loadComponent: () => import('./core/mod/moderacion-page/moderacion-page.component').then(m => m.ModeracionPageComponent)},
  { path: '**', redirectTo: 'login' },
];
