package com.enmer.proyect2.admin.dto;

import java.math.BigDecimal;
import java.util.List;

public record ResumenAdmin(
        List<KV> productosPorEstado,
        List<KV> pedidosPorEstado,
        BigDecimal ventasHoy
) {
}
