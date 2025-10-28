package com.enmer.proyect2.producto.pedidos;


import com.enmer.proyect2.producto.Producto;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "items_pedido", schema = "ecommerce_gt")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PedidoItem {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_pedido", nullable = false)
    private Pedido pedido;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    @Column(name = "id_vendedor", nullable = false)
    private Long idVendedor;

    @Column(nullable = false)
    private Integer cantidad;

    @Column(name = "precio_unitario", nullable = false)
    private BigDecimal precioUnitario;

    @Column(name = "ganancia_vendedor", insertable = false, updatable = false)
    private BigDecimal gananciaVendedor;

    @Column(name = "comision_plataforma", insertable = false, updatable = false)
    private BigDecimal comisionPlataforma;

}
