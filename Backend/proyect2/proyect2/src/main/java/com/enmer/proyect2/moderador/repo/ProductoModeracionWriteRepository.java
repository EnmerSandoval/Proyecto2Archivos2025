package com.enmer.proyect2.moderador.repo;

import com.enmer.proyect2.producto.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductoModeracionWriteRepository extends JpaRepository<Producto, Long> {
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
      update Producto p
      set p.estado = :nuevo,
          p.motivoRechazo = null,
          p.revisadoEn = CURRENT_TIMESTAMP,
          p.revisadoPor = :moderador
      where p.id = :id and p.estado = :esperado
    """)
    int aprobar(@Param("id") Long id,
                @Param("moderador") com.enmer.proyect2.auth.Usuario moderador,
                @Param("nuevo") com.enmer.proyect2.enums.EstadoProducto nuevo,
                @Param("esperado") com.enmer.proyect2.enums.EstadoProducto esperado);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
      update Producto p
      set p.estado = :nuevo,
          p.motivoRechazo = :motivo,
          p.revisadoEn = CURRENT_TIMESTAMP,
          p.revisadoPor = :moderador
      where p.id = :id and p.estado = :esperado
    """)
    int rechazar(@Param("id") Long id,
                 @Param("motivo") String motivo,
                 @Param("moderador") com.enmer.proyect2.auth.Usuario moderador,
                 @Param("nuevo") com.enmer.proyect2.enums.EstadoProducto nuevo,
                 @Param("esperado") com.enmer.proyect2.enums.EstadoProducto esperado);

}
