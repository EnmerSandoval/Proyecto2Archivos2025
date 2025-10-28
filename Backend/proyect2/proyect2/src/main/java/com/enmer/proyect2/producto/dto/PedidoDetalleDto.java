package com.enmer.proyect2.producto.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record PedidoDetalleDto(
        Long id,
        String estado,
        BigDecimal montoTotal,
        Instant realizadoEn,
        String direccionEnvio,
        List<ItemDto> items
) {
    public record ItemDto(
            Long productoId,
            String nombre,
            Integer cantidad,
            BigDecimal precioUnitario,
            BigDecimal subtotal,
            String imagenUrl
    ) {}
}
