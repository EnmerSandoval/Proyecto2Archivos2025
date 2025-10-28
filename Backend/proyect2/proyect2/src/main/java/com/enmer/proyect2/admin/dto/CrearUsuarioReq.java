package com.enmer.proyect2.admin.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CrearUsuarioReq(
        @NotBlank @Email String email,
        @NotBlank String nombre,
        @NotBlank @Size(min = 6, max = 100) String password,
        @NotBlank String rol
) {
}
