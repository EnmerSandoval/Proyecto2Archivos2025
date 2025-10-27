package com.enmer.proyect2.producto.carrito;

import com.enmer.proyect2.enums.EstadoCarrito;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CarritoRepository extends JpaRepository<Carrito, Long> {
    Optional<Carrito> findFirstByUsuarioIdAndEstadoOrderByIdDesc(Long uid, EstadoCarrito estado);
}
