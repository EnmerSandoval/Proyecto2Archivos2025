package com.enmer.proyect2.producto.carrito.Dto;

import java.math.BigDecimal;
import java.util.List;

public record CarritoDto(
        Long id, List<ItemDto> items, BigDecimal total
) {
    public record ItemDto(
            Long id, Long productoId, String nombre, String imagenUrl,
            Integer cantidad, BigDecimal precioUnitario, BigDecimal subtotal
    ) {}
}

