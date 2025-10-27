package com.enmer.proyect2.producto.dto;

import com.enmer.proyect2.enums.CondicionProducto;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;

public record CrearProductoRequest(

    @NotBlank
    @Size(max = 160) String nombre,
    @NotBlank String descripcion,
    String imagenUrl,
    @NotNull
    @DecimalMin(value = "0.01")
    BigDecimal precio,
    @NotNull @Min(0) Integer stock,
    @NotNull
    CondicionProducto condicion,
    @NotNull Long idCategoria
){}
