package com.enmer.proyect2.logistica.repo;

import com.enmer.proyect2.producto.pedidos.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;

public interface PedidoLogisticaWriteRepository extends JpaRepository<Pedido, Long> {
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("update Pedido p set p.estado = 'en_curso' where p.id = :id and p.estado = 'creado'")
    int marcarEnRuta(@Param("id") Long id);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
     update Pedido p
     set p.estado = 'entregado', p.fechaEntrega = CURRENT_TIMESTAMP
     where p.id = :id and (p.estado = 'en_curso' or p.estado = 'creado')
  """)
    int marcarEntregado(@Param("id") Long id);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
     update Pedido p
     set p.fechaPrometidaEntrega = :nueva
     where p.id = :id and p.estado <> 'entregado' and p.estado <> 'cancelado'
  """)
    int reprogramarPromesa(@Param("id") Long id, @Param("nueva") Instant nueva);
}
