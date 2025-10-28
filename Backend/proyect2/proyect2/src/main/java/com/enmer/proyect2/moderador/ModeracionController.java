package com.enmer.proyect2.moderador;

import com.enmer.proyect2.moderador.dto.ProductoView;
import com.enmer.proyect2.moderador.dto.RechazoRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/moderacion")
@RequiredArgsConstructor
public class ModeracionController {

    private final ModeracionService service;

    @GetMapping("/productos")
    @PreAuthorize("hasRole('MODERADOR')")
    public Page<ProductoView> listar(@RequestParam(required = false) String estado,
                                     @RequestParam(defaultValue = "0") int page,
                                     @RequestParam(defaultValue = "20") int size) {
        return service.listar(estado, PageRequest.of(page, size));
    }

    @PatchMapping("/productos/{id}/aprobar")
    @PreAuthorize("hasRole('MODERADOR')")
    public void aprobar(@PathVariable Long id, Authentication auth) {
        service.aprobar(id, auth);
    }

    @PatchMapping("/productos/{id}/rechazar")
    @PreAuthorize("hasRole('MODERADOR')")
    public void rechazar(@PathVariable Long id,
                         @RequestBody RechazoRequest req,
                         Authentication auth) {
        service.rechazar(id, req.motivo(), auth);
    }
}
