package com.enmer.proyect2.auth;

import java.time.Instant;

public class LoginResponse {
    private String token;
    private Instant expiresAt;
    private String email;
    private String nombre;
    private String rol;

    public LoginResponse(String token, Instant expiresAt, String email, String nombre, String rol){
        this.token = token;
        this.expiresAt = expiresAt;
        this.email = email;
        this.nombre = nombre;
        this.rol = rol;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Instant expiresAt) {
        this.expiresAt = expiresAt;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }
}

