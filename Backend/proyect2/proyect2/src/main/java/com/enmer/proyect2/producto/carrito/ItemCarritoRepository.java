package com.enmer.proyect2.producto.carrito;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ItemCarritoRepository extends JpaRepository<ItemCarrito, Long> {
    Optional<ItemCarrito> findByCarrito_IdAndProducto_Id(Long carritoId, Long productoId);
}
