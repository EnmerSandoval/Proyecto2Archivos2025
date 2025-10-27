import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { Producto } from '../productos.model';

@Component({
  selector: 'app-producto-card',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './producto-card.component.html',
  styleUrl: './producto-card.component.scss'
})
export class ProductoCardComponent {
  @Input() p!: Producto;
}
