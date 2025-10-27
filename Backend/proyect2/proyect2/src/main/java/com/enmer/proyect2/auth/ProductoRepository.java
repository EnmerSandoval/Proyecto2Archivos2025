package com.enmer.proyect2.auth; // (ideal mover a com.enmer.proyect2.producto)

import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.Producto;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface ProductoRepository extends JpaRepository<Producto, Long> {

    Page<Producto> findByEstado(EstadoProducto estado, Pageable pageable);

    @Query("""
      SELECT p
      FROM Producto p
      WHERE p.estado = :estado
        AND (:catId IS NULL OR p.categoria.id = :catId)
        AND (:pattern IS NULL OR
             LOWER(p.nombre) LIKE :pattern OR
             LOWER(p.descripcion) LIKE :pattern)
      ORDER BY p.id DESC
    """)
    Page<Producto> buscarCatalogo(@Param("estado") EstadoProducto estado,
                                  @Param("catId") Long catId,
                                  @Param("pattern") String pattern,
                                  Pageable pageable);

    @Query("""
       SELECT p FROM Producto p
       WHERE p.vendedor.id = :uid
         AND (:estado IS NULL OR p.estado = :estado)
         AND (:q IS NULL OR
              LOWER(p.nombre) LIKE LOWER(CONCAT('%', :q, '%')) OR
              LOWER(p.descripcion) LIKE LOWER(CONCAT('%', :q, '%')))
       ORDER BY p.id DESC
       """)
    Page<Producto> buscarPorVendedor(@Param("uid") Long usuarioId,
                                     @Param("estado") EstadoProducto estado,
                                     @Param("q") String q,
                                     Pageable pageable);

}
