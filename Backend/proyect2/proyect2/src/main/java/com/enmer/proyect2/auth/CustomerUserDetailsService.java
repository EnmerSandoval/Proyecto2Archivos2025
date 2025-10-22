package com.enmer.proyect2.auth;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomerUserDetailsService implements UserDetailsService {
    private final UserRepository repo;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException{
        Usuario u = repo.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("No existe el usuario con el email " + email));
        var auth = List.of(new SimpleGrantedAuthority("ROLE_"+u.getRol()));
        return User.builder()
                .username(u.getEmail())
                .password(u.getPasswordHash())
                .authorities(auth)
                .accountLocked(!u.isActivo())
                .build();
    }
}
