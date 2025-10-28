package com.enmer.proyect2.logistica;

import com.enmer.proyect2.logistica.dto.PedidoView;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/logistica")
@RequiredArgsConstructor
public class LogisticaController {
    private final LogisticaService service;

    @GetMapping("/pedidos")
    @PreAuthorize("hasRole('LOGISTICA')")
    public Page<PedidoView> listar(@RequestParam(required=false) String estado,
                                   @RequestParam(defaultValue="0") int page,
                                   @RequestParam(defaultValue="20") int size) {
        return service.listar(estado, PageRequest.of(page, size));
    }

    @PatchMapping("/pedidos/{id}/en-ruta")
    @PreAuthorize("hasRole('LOGISTICA')")
    public void enRuta(@PathVariable Long id) { service.enRuta(id); }

    @PatchMapping("/pedidos/{id}/entregado")
    @PreAuthorize("hasRole('LOGISTICA')")
    public void entregado(@PathVariable Long id) { service.entregado(id); }

}
