package com.enmer.proyect2.producto.dto;

import com.enmer.proyect2.enums.CondicionProducto;
import com.enmer.proyect2.enums.EstadoProducto;

import java.math.BigDecimal;
import java.time.Instant;

public record ProductoDetalleDto(
        Long id,
        String nombre,
        String descripcion,
        String imagenUrl,
        BigDecimal precio,
        Integer stock,
        CondicionProducto condicion,
        Long idCategoria,
        EstadoProducto estado,
        Instant creadoEn,
        Instant fechaActualizada
) {
}
