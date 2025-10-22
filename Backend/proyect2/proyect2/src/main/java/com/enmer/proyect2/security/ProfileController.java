package com.enmer.proyect2.security;

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;

@RestController
@RequestMapping("/api/me")
public class ProfileController {
    @GetMapping
    public Object me(Authentication auth) {
        return new Object(){public final String user = auth.getName();};
    }
}
