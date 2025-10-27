package com.enmer.proyect2.auth;

import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.Producto;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface ProductoRepository extends JpaRepository<Producto, Long> {

    Page<Producto> findByEstado(EstadoProducto estado, Pageable pageable);

    @Query(value = """
      SELECT *
      FROM ecommerce_gt.productos p
      WHERE p.estado = 'aprobado'
        AND (:catId IS NULL OR p.id_categoria = :catId)
        AND (
          :q IS NULL OR
          p.nombre ILIKE CONCAT('%', :q, '%') OR
          p.descripcion ILIKE CONCAT('%', :q, '%')
        )
      """,
            countQuery = """
      SELECT COUNT(*)
      FROM ecommerce_gt.productos p
      WHERE p.estado = 'aprobado'
        AND (:catId IS NULL OR p.id_categoria = :catId)
        AND (
          :q IS NULL OR
          p.nombre ILIKE CONCAT('%', :q, '%') OR
          p.descripcion ILIKE CONCAT('%', :q, '%')
        )
      """,
            nativeQuery = true)
    Page<Producto> buscarCatalogo(@Param("catId") Long catId,
                                  @Param("q") String q,
                                  Pageable pageable);
}
