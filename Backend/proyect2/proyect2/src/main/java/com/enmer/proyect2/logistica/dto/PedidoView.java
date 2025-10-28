package com.enmer.proyect2.logistica.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record PedidoView(
        Long id,
        Long idComprador,
        String estado,
        Instant creadoEn,
        Instant fechaPrometidaEntrega,
        Instant fechaEntrega,
        String direccionEnvio,
        BigDecimal montoTotal
) {
}
