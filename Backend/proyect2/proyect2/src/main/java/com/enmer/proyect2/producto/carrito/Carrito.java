package com.enmer.proyect2.producto.carrito;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoCarrito;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "carritos", schema = "ecommerce_gt")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Carrito {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false) @JoinColumn(name="id_usuario")
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    @Column(name="estado", nullable=false)
    private EstadoCarrito estado = EstadoCarrito.activo;

    @CreationTimestamp
    @Column(name="creado_en", updatable=false)
    private OffsetDateTime creadoEn;

    @UpdateTimestamp
    @Column(name="fecha_actualizada")
    private OffsetDateTime fechaActualizada;

    @OneToMany(mappedBy = "carrito", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ItemCarrito> items = new ArrayList<>();
}
