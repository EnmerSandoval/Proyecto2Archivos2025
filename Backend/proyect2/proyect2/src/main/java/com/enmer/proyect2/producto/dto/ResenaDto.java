package com.enmer.proyect2.producto.dto;

import java.time.Instant;

public record ResenaDto(
        Long id,
        Long idProducto,
        Long idComprador,
        Integer calificacion,
        String comentario,
        Instant creadoEn,
        String compradorNombre
) {
}
