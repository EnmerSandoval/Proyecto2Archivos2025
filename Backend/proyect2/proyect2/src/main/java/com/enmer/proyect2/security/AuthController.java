package com.enmer.proyect2.security;

import com.enmer.proyect2.auth.*;
import com.enmer.proyect2.auth.dto.LoginResponse;
import com.enmer.proyect2.auth.dto.SignupRequest;
import com.enmer.proyect2.enums.RolUsuario;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.enmer.proyect2.auth.UserRepository;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authManager;
    private final JwtService jwtService;
    private final UserRepository repo;
    private final PasswordEncoder encoder;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        try {
            Authentication auth = authManager.authenticate(
                    new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword()));
            String email = auth.getName();
            String role = auth.getAuthorities().stream().findFirst().map(a -> a.getAuthority()).orElse("ROLE_COMUN");
            String token = jwtService.generate(email, role);
            return ResponseEntity.ok(new LoginResponse(token, jwtService.getTtlMs()));
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(401).build();
        }
    }

    @Bean
    CommandLineRunner printBcrypt(PasswordEncoder encoder) {
        return args -> {
            System.out.println("BCRYPT(password) = " + encoder.encode("password"));
        };
    }

    @PostMapping({"/register", "/signup"})
    public ResponseEntity<Void> register(@Valid @RequestBody SignupRequest req) {
        final String email = req.email().trim().toLowerCase();
        if (repo.existsByEmail(email)) {
            return ResponseEntity.status(409).build();
        }
        Usuario u = Usuario.builder()
                .nombre(req.nombre().trim())
                .email(email)
                .passwordHash(encoder.encode(req.password()))
                .rol(RolUsuario.comun)
                .activo(true)
                .build();
        repo.save(u);
        return ResponseEntity.status(201).build();
    }
}
