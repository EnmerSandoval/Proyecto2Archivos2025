import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Producto } from '../productos.model';

@Component({
  selector: 'app-producto-card',
  standalone: true,
  imports: [CommonModule, RouterModule], // <-- NgIf, NgClass, pipes, routerLink
  templateUrl: './producto-card.component.html'
})
export class ProductoCardComponent {
  @Input({ required: true }) p!: Producto;
  @Input() showAddToCart = false;
  @Output() addToCart = new EventEmitter<void>();

  canBuy() {
    return this.p.estado === 'aprobado' && (this.p.stock ?? 0) > 0;
  }
  agregar() { this.addToCart.emit(); }
}
