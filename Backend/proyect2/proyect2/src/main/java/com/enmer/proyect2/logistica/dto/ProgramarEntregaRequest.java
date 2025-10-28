package com.enmer.proyect2.logistica.dto;

import java.time.Instant;

public record ProgramarEntregaRequest(
        Instant fechaPrometidaEntrega
) {
}
