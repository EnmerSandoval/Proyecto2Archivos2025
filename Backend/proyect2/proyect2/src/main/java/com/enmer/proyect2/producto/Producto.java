package com.enmer.proyect2.producto;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.CondicionProducto;
import com.enmer.proyect2.enums.EstadoProducto;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "productos", schema = "ecommerce_gt")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Producto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_vendedor", nullable = false)
    private Usuario vendedor;

    @Column(nullable = false, length = 160)
    private String nombre;

    @Column(nullable = false, columnDefinition = "text")
    private String descripcion;

    @Column(name = "imagen_url")
    private String imagenUrl;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal precio;

    @Column(nullable = false)
    private Integer stock;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "ecommerce_gt.condicion_producto")
    private CondicionProducto condicion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_categoria", nullable = false)
    private Categoria categoria;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "ecommerce_gt.estado_producto")
    private EstadoProducto estado;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "revisado_por")
    private Usuario revisadoPor;

    @Column(name = "revisado_en")
    private Instant revisadoEn;

    @Column(name = "motivo_rechazo", columnDefinition = "text")
    private String motivoRechazo;

    @Column(name = "creado_en", updatable = false)
    private Instant creadoEn;

    @Column(name = "fecha_actualizada")
    private Instant fechaActualizada;

    @PrePersist
    void prePersist() {
        if (estado == null) estado = EstadoProducto.pendiente;
        creadoEn = Instant.now();
        fechaActualizada = Instant.now();
    }

    @PreUpdate
    void preUpdate() {
        fechaActualizada = Instant.now();
    }
}
