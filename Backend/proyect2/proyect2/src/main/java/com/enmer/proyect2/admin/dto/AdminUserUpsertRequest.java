package com.enmer.proyect2.admin.dto;

public record AdminUserUpsertRequest(
        String email,
        String nombre,
        String password,
        String rol
) {
}
