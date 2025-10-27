package com.enmer.proyect2.producto.carrito;

import com.enmer.proyect2.producto.Producto;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "items_carrito", schema = "ecommerce_gt")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ItemCarrito {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional=false) @JoinColumn(name="id_carrito")
    private Carrito carrito;

    @ManyToOne(optional=false) @JoinColumn(name="id_producto")
    private Producto producto;

    @Column(nullable=false)
    private Integer cantidad;

    @Column(name="precio_unitario", nullable=false, precision=14, scale=2)
    private BigDecimal precioUnitario;

    @CreationTimestamp
    @Column(name="creado_en", updatable=false)
    private OffsetDateTime creadoEn;
}
