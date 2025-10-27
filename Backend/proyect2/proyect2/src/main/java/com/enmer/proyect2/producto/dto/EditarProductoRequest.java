package com.enmer.proyect2.producto.dto;

import com.enmer.proyect2.enums.CondicionProducto;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record EditarProductoRequest(
        @NotBlank String nombre,
        @NotBlank String descripcion,
        String imagenUrl,
        @NotNull @DecimalMin(value = "0.01") BigDecimal precio,
        @NotNull @Min(0) Integer stock,
        @NotNull CondicionProducto condicion,
        @NotNull Long idCategoria
) {
}
