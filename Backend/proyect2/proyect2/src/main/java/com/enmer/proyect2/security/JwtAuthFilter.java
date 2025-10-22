package com.enmer.proyect2.security;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component @RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtService jwtService;
    private final DbUserDetailService uds;

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain fc) throws ServletException, IOException{
        var header = req.getHeader("Authorization");
        if(header != null && header.startsWith("Bearer ")){
            var token = header.substring(7);
            try{
                var email = jwtService.validateAndGetSubject(token);
                var role = jwtService.getRole(token);
                var userDetails = uds.loadUserByUsername(email);
                var auth = new UsernamePasswordAuthenticationToken(userDetails, null, List.of(new SimpleGrantedAuthority(role)));
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (Exception e){}
        }
        fc.doFilter(req, res);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request)  {
        var p = request.getServletPath();
        return p.equals("/api/auth/");
    }

}
