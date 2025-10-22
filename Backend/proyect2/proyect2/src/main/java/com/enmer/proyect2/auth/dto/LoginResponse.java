package com.enmer.proyect2.auth.dto;

import com.enmer.proyect2.auth.Usuario;

public record LoginResponse (String token, long expiresIn) {
}
