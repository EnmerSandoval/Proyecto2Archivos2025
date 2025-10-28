package com.enmer.proyect2.producto.pedidos;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

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

    Page<Pedido> findByCompradorIdOrderByIdDesc(Long compradorId, Pageable pageable);
    Optional<Pedido> findByIdAndCompradorId(Long id, Long compradorId);

    interface EstadoCount { String getEstado(); long getTotal(); }

    @Query("""
      select p.estado as estado, count(p) as total
      from Pedido p
      group by p.estado
      order by p.estado
    """)
    List<EstadoCount> resumenPorEstado();

    interface VentasDia {
        java.time.LocalDate getDia();
        java.math.BigDecimal getMonto();
        long getPedidos();
    }

    @Query(value = """
      select date_trunc('day', coalesce(p.fecha_entrega, p.fecha_prometida_entrega))::date as dia,
             coalesce(sum(p.monto_total),0)                                                as monto,
             count(*)                                                                      as pedidos
      from ecommerce_gt.pedidos p
      where coalesce(p.fecha_entrega, p.fecha_prometida_entrega) is not null
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) >= now() - (:dias || ' days')::interval
      group by 1
      order by 1
    """, nativeQuery = true)
    List<VentasDia> ventasUltimosDias(@Param("dias") int dias);

    interface TopVendedor {
        Long getVendedorId();
        String getVendedorNombre();
        Long getItems();
        java.math.BigDecimal getMontoBruto();
        java.math.BigDecimal getGananciaVendedor();
        java.math.BigDecimal getComisionPlataforma();
    }

    @Query(value = """
      select ip.id_vendedor                          as vendedorId,
             u.nombre                                as vendedorNombre,
             sum(ip.cantidad)                        as items,
             sum(ip.precio_unitario * ip.cantidad)   as montoBruto,
             sum(ip.ganancia_vendedor)               as gananciaVendedor,
             sum(ip.comision_plataforma)             as comisionPlataforma
      from ecommerce_gt.items_pedido ip
      join ecommerce_gt.pedidos p  on p.id = ip.id_pedido
      join ecommerce_gt.usuarios u on u.id = ip.id_vendedor
      where p.estado in ('en_curso','entregado')
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) is not null
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) >= now() - (:dias || ' days')::interval
      group by 1,2
      order by gananciaVendedor desc
      limit :limite
    """, nativeQuery = true)
    List<TopVendedor> topVendedores(@Param("dias") int dias, @Param("limite") int limite);

    interface TopProducto {
        Long getProductoId();
        String getNombre();
        Long getItems();
        java.math.BigDecimal getTotal();
    }

    @Query(value = """
      select ip.id_producto                           as productoId,
             pr.nombre                                 as nombre,
             sum(ip.cantidad)                          as items,
             sum(ip.precio_unitario * ip.cantidad)     as total
      from ecommerce_gt.items_pedido ip
      join ecommerce_gt.pedidos p   on p.id = ip.id_pedido
      join ecommerce_gt.productos pr on pr.id = ip.id_producto
      where p.estado in ('en_curso','entregado')
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) is not null
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) >= now() - (:dias || ' days')::interval
      group by 1,2
      order by total desc
      limit :limite
    """, nativeQuery = true)
    List<TopProducto> topProductos(@Param("dias") int dias, @Param("limite") int limite);

    interface TopComprador {
        Long getCompradorId();
        String getCompradorNombre();
        Long getPedidos();
        java.math.BigDecimal getTotal();
    }

    @Query(value = """
      select p.id_comprador                 as compradorId,
             u.nombre                       as compradorNombre,
             count(*)                       as pedidos,
             sum(p.monto_total)             as total
      from ecommerce_gt.pedidos p
      join ecommerce_gt.usuarios u on u.id = p.id_comprador
      where p.estado in ('en_curso','entregado')
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) is not null
        and coalesce(p.fecha_entrega, p.fecha_prometida_entrega) >= now() - (:dias || ' days')::interval
      group by 1,2
      order by total desc
      limit :limite
    """, nativeQuery = true)
    List<TopComprador> topCompradores(@Param("dias") int dias, @Param("limite") int limite);

}

