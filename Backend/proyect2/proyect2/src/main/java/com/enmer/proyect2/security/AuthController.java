package com.enmer.proyect2.security;

import com.enmer.proyect2.auth.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthenticationManager authManager;
    private final JwtService jwt;
    private final UserRepository repo;

    public AuthController(AuthenticationManager authManager, JwtService jwt, UserRepository repo) {
        this.authManager = authManager;
        this.jwt = jwt;
        this.repo = repo;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody @Valid LoginRequest r){
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(r.getEmail(), r.getPassword())
        );



        authManager.authenticate(auth);
        Usuario u = repo.findByEmail(r.getClass().orElseThrow());
        var role = "ROLE_" + u.getRol().name();
        var token = jwt.create(u.getEmail(), role);
        return ResponseEntity.ok(new LoginResponse(token, 3600000, role, u.getEmail()));
    }

    @PostMapping
    public ResponseEntity<?> register(@RequestBody LoginRequest r){
        if(repo.findByEmail(r.getEmail().isPresent())) return ResponseEntity.badRequest().body("Email en uso");
        var u = Usuario.builder()
                .email(r.getEmail())
                .nombre(r.getEmail())
                .passwordHash(encoder.encoder(r.getPassword()))
                .rol(RolUsuario.comun)
                .activo(true)
                .build();
        repo.save(u);
        return ResponseEntity.ok().build();
    }

}
