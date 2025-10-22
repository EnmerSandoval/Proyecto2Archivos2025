package com.enmer.proyect2.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Date;

@Service
public class JwtService {
    private final Algorithm algorithm;
    private final long ttlMs;

    public JwtService(@Value("{app.jwt.secret}") String secret, @Value("${app.jwt.ttl-ms}") long ttlMs) {
        this.algorithm = Algorithm.HMAC256(secret);
        this.ttlMs = ttlMs;
    }

    public String create(String subject, String role){
        var now = Instant.now();
        return JWT.create()
                .withSubject(subject)
                .withClaim("role", role)
                .withIssuedAt(Date.from(now))
                .withExpiresAt(Date.from(now.plusMillis(ttlMs)))
                .sign(algorithm);
    }

    public String validateAndGetSubject(String token){
        return JWT.require(algorithm).build().verify(token).getSubject();
    }

    public String getRole(String token){
        return JWT.require(algorithm).build().verify(token).getClaim("role").asString();
    }

}
