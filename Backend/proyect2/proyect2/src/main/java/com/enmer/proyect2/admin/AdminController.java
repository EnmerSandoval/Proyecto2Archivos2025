package com.enmer.proyect2.admin;

import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.RolUsuario;
import com.enmer.proyect2.producto.pedidos.PedidoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

        @GetMapping("/reportes/pedidos-por-estado")
    public List<PedidoRepository.EstadoCount> pedidosPorEstado() {
        return service.pedidosPorEstado();
    }

    @GetMapping("/reportes/ventas-ultimos-dias")
    public List<PedidoRepository.VentasDia> ventasUltimosDias(@RequestParam(defaultValue="7") int dias) {
        return service.ventasUltimosDias(dias);
    }

    @GetMapping("/reportes/top-vendedores")
    public List<PedidoRepository.TopVendedor> topVendedores(
            @RequestParam(defaultValue="7") int dias,
            @RequestParam(defaultValue="10") int limite) {
        return service.topVendedores(dias, limite);
    }

    @GetMapping("/reportes/top-productos")
    public List<PedidoRepository.TopProducto> topProductos(
            @RequestParam(defaultValue="7") int dias,
            @RequestParam(defaultValue="10") int limite) {
        return service.topProductos(dias, limite);
    }

    @GetMapping("/reportes/top-compradores")
    public List<PedidoRepository.TopComprador> topCompradores(
            @RequestParam(defaultValue="7") int dias,
            @RequestParam(defaultValue="10") int limite) {
        return service.topCompradores(dias, limite);
    }

}
