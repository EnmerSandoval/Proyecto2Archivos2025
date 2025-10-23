package com.enmer.proyect2.security;

import com.enmer.proyect2.auth.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Primary;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Service;

@Service
@Primary
@RequiredArgsConstructor
public class DbUserDetailService implements UserDetailsService {
    private final UserRepository repo;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException{
        var user = repo.findByEmail(email).orElseThrow(()-> new UsernameNotFoundException("No existe el usuario"));
        var auth = switch (user.getRol()){
            case admin -> "ROLE_ADMIN";
            case moderador -> "ROLE_MODERADOR";
            case logistica -> "ROLE_LOGISTICA";
            default -> "ROLE_COMUN";
        };
        return User
                .withUsername(user.getEmail())
                .password(user.getPasswordHash())
                .authorities(auth)
                .accountLocked(!user.isActivo())
                .build();
    }
}
