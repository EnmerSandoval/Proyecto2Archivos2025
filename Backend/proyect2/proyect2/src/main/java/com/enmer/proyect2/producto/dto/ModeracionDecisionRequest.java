package com.enmer.proyect2.producto.dto;

import jakarta.validation.constraints.NotBlank;

public record ModeracionDecisionRequest(
        @NotBlank String motivo
) {
}
