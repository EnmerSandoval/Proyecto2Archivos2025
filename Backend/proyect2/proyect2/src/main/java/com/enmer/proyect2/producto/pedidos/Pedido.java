package com.enmer.proyect2.producto.pedidos;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoPedido;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "pedidos", schema = "ecommerce_gt")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Pedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_comprador", nullable = false)
    private Usuario comprador;

    @Column(name = "id_direccion_envio")
    private Long idDireccionEnvio;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false)
    private EstadoPedido estado;

    @Column(name = "realizado_en", insertable = false, updatable = false)
    private Instant realizadoEn;

    @Column(name = "fecha_prometida_entrega", insertable = false)
    private LocalDate fechaPrometidaEntrega;

    @Column(name = "fecha_entrega")
    private LocalDate fechaEntrega;

    @Column(name = "monto_total", insertable = false)
    private BigDecimal montoTotal;

    @PrePersist
    void prePersist() {
        if (estado == null) estado = EstadoPedido.en_curso;
    }
}
