package com.enmer.proyect2.producto.resena;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.producto.Producto;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(
        name = "resenas_producto",
        schema = "ecommerce_gt",
        uniqueConstraints = @UniqueConstraint(
                name = "ux_resena_unica",
                columnNames = { "id_comprador", "id_producto"}
        )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResenaProducto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_comprador", nullable = false)
    private Usuario comprador;

    @Column(nullable = false)
    private Short calificacion;

    @Column
    private String comentario;

    @Column(name = "creado_en", insertable = false, updatable = false)
    private Instant creadoEn;
}
