package com.enmer.proyect2.auth;

import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.Producto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

    Page<Producto> findByVendedorId(Long uid, Pageable pageable);

    Page<Producto> findByVendedorIdAndEstado(Long uid, EstadoProducto estado, Pageable pageable);

    @Query("""
       SELECT p FROM Producto p
       WHERE p.vendedor.id = :uid
         AND (LOWER(p.nombre) LIKE :pattern OR LOWER(p.descripcion) LIKE :pattern)
       ORDER BY p.id DESC
       """)
    Page<Producto> buscarPorVendedorConBusqueda(@Param("uid") Long uid,
                                                @Param("pattern") String pattern,
                                                Pageable pageable);

    @Query("""
       SELECT p FROM Producto p
       WHERE p.vendedor.id = :uid
         AND p.estado = :estado
         AND (LOWER(p.nombre) LIKE :pattern OR LOWER(p.descripcion) LIKE :pattern)
       ORDER BY p.id DESC
       """)
    Page<Producto> buscarPorVendedorConBusquedaYEstado(@Param("uid") Long uid,
                                                       @Param("estado") EstadoProducto estado,
                                                       @Param("pattern") String pattern,
                                                       Pageable pageable);
}
