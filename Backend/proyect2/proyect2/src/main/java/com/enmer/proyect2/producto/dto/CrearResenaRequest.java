package com.enmer.proyect2.producto.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CrearResenaRequest(
        @NotNull @Min(1) @Max(5) Integer calificacion,
        @Size(max = 2000) String comentario
) {
}
