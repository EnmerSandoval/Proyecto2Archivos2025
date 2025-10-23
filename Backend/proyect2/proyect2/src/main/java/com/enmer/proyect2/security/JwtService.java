package com.enmer.proyect2.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Getter
    @Value("${app.jwt.ttl-ms}")
    private long ttlMs;

    public String generate(String subject, String role) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + ttlMs);
        return JWT.create()
                .withSubject(subject)
                .withClaim("role", role)
                .withIssuedAt(now)
                .withExpiresAt(exp)
                .sign(Algorithm.HMAC256(secret));
    }

    public DecodedJWT verify(String token) {
        return JWT.require(Algorithm.HMAC256(secret)).build().verify(token);
    }

    public long ttlMs() {
        return ttlMs;
    }

}
