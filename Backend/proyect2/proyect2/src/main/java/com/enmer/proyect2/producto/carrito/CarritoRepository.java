package com.enmer.proyect2.producto.carrito;

import com.enmer.proyect2.enums.EstadoCarrito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CarritoRepository extends JpaRepository<Carrito, Long> {

      @Query("""
        select c from Carrito c
        where c.usuario.id = :uid
          and c.estado = com.enmer.proyect2.enums.EstadoCarrito.activo
        order by c.id desc
      """)
    Optional<Carrito> findAbiertoByUsuario(@Param("uid") Long uid);
}
