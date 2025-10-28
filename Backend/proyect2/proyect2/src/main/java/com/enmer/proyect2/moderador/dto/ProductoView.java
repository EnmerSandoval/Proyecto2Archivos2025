package com.enmer.proyect2.moderador.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record ProductoView(
        Long id,
        String nombre,
        BigDecimal precio,
        String estado, String rechazoMotivo,
        Instant moderadoEn, Long moderadoPor,
        Long vendedorId
) {
}
