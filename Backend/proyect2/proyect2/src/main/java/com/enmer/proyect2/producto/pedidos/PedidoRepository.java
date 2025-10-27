package com.enmer.proyect2.producto.pedidos;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    @Query(value = """
      select exists(
        select 1
        from ecommerce_gt.pedidos p
        join ecommerce_gt.items_pedido ip on ip.id_pedido = p.id
        where p.estado = 'entregado'
          and p.id_comprador = :uid
          and ip.id_producto = :pid
      )
    """, nativeQuery = true)
    boolean hasDeliveredPurchase(@Param("uid") Long usuarioId,
                                 @Param("pid") Long productoId);
}
