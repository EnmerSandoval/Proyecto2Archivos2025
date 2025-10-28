package com.enmer.proyect2.producto.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record PedidoListDto(
        Long id,
        String estado,
        BigDecimal montoTotal,
        Instant realizadoEn
) {
}
