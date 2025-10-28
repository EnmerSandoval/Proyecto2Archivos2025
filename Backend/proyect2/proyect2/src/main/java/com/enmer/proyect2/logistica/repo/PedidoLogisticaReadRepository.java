package com.enmer.proyect2.logistica.repo;

import com.enmer.proyect2.producto.pedidos.Pedido;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PedidoLogisticaReadRepository extends JpaRepository<Pedido, Long> {
    @Query("""
    select p from Pedido p
    where (:estado is null or p.estado = :estado)
    order by p.id desc
  """)
    Page<Pedido> findByEstado(@Param("estado") String estado, Pageable pageable);
}
