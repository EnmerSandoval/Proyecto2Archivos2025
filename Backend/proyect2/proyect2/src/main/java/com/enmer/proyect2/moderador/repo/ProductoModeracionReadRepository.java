package com.enmer.proyect2.moderador.repo;

import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.Producto;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface ProductoModeracionReadRepository extends JpaRepository<Producto, Long> {

    Page<Producto> findAllByOrderByIdDesc(Pageable pageable);

    Page<Producto> findByEstadoOrderByIdDesc(EstadoProducto estado, Pageable pageable);

    @Query("select p from Producto p where p.estado = :estado order by p.id desc")
    Page<Producto> listarSoloEstado(EstadoProducto estado, Pageable pageable);
}
