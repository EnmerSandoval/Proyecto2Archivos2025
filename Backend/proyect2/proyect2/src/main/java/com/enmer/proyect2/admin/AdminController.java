package com.enmer.proyect2.admin;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.RolUsuario;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('admin')")
public class AdminController {
    private final AdminService service;

    @GetMapping("/usuarios")
    public Page<Usuario> usuarios(@RequestParam String rol,
                                  @RequestParam(defaultValue="0") int page,
                                  @RequestParam(defaultValue="20") int size) {
        return service.listarPorRol(parseRol(rol), PageRequest.of(page, size));
    }

    public record AsignarRolReq(String email, String rol) {}

    @PostMapping("/usuarios/asignar-rol")
    public void asignarRol(@RequestBody AsignarRolReq req) {
        service.asignarRolPorEmail(req.email(), parseRol(req.rol()));
    }

    private RolUsuario parseRol(String raw) {
        for (RolUsuario r : RolUsuario.values()) {
            if (r.name().equalsIgnoreCase(raw)) return r;
        }
        throw new IllegalArgumentException("Rol inválido. Usa: moderador | logistica");
    }
}
