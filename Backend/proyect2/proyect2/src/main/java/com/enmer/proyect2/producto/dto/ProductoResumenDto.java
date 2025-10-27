package com.enmer.proyect2.producto.dto;

import java.math.BigDecimal;

public record ProductoResumenDto(
        Long id,
        String nombre,
        BigDecimal precio,
        Integer stock,
        String condicion,
        String imagenUrl,
        Long categoriaId,
        String estado,
        String motivoRechazo
) {
}
