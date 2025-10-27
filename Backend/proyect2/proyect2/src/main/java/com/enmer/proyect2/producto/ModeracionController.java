package com.enmer.proyect2.producto;

import com.enmer.proyect2.auth.ProductoRepository;
import com.enmer.proyect2.producto.dto.ModeracionDecisionRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/moderacion")
@RequiredArgsConstructor
public class ModeracionController {

    private final ProductoService service;

    @GetMapping("/ingresos")
    public Page<Producto> pendientes(@RequestParam(defaultValue = "0") int page,
                                     @RequestParam(defaultValue = "20") int size
                                     ){
        return service.pendientes(PageRequest.of(page, Math.min(size, 100)));
    }

    @PostMapping("/ingresos/{id}/aprobar")
    public ResponseEntity<Void> aprobar(@PathVariable Long id) {
        service.aprobar(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/ingresos/{id}/rechazar")
    public ResponseEntity<Void> rechazar(@PathVariable Long id,
                                         @RequestBody @Valid ModeracionDecisionRequest body) {
        service.rechazar(id, body.motivo());
        return ResponseEntity.noContent().build();
    }


}
