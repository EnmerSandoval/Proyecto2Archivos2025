package com.enmer.proyect2.security;

import com.enmer.proyect2.auth.*;
import com.enmer.proyect2.auth.dto.SignupRequest;
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
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword()));
        String email = auth.getName();
        String role = auth.getAuthorities().stream().findFirst().map(a -> a.getAuthority()).orElse("ROLE_COMUN");
        String token = jwtService.generate(email, role);
        return ResponseEntity.ok(new LoginResponse(token, jwtService.ttlMs()));
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest req) {
        if (repo.existsByEmail(req.email())) return ResponseEntity.badRequest().body("Email en uso");
        Usuario u = Usuario.builder()
                .nombre(req.nombre())
                .email(req.email())
                .passwordHash(encoder.encode(req.password()))
                .rol(RolUsuario.comun)
                .activo(true)
                .build();
        repo.save(u);
        return ResponseEntity.ok().build();
    }

}
