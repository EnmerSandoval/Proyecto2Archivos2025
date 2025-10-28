package com.enmer.proyect2.admin;

import com.enmer.proyect2.auth.UserRepository;
import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.RolUsuario;
import com.enmer.proyect2.producto.pedidos.PedidoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final UserRepository users;
    private final PedidoRepository pedidos;

    @Transactional(readOnly = true)
    public Page<Usuario> listarPorRol(RolUsuario rol, Pageable pageable) {
        if (rol != RolUsuario.moderador && rol != RolUsuario.logistica) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Rol soportado: moderador | logistica");
        }
        return users.findByRolOrderByIdDesc(rol, pageable);
    }

    @Transactional
    public void asignarRolPorEmail(String email, RolUsuario nuevoRol) {
        if (nuevoRol != RolUsuario.moderador && nuevoRol != RolUsuario.logistica) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Solo se puede asignar moderador o logistica");
        }
        Usuario u = users.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe usuario: " + email));
        u.setRol(nuevoRol);
        users.save(u);
    }

    @Transactional(readOnly = true) public List<PedidoRepository.EstadoCount> pedidosPorEstado() { return pedidos.resumenPorEstado(); }
    @Transactional(readOnly = true) public List<PedidoRepository.VentasDia> ventasUltimosDias(int dias) { return pedidos.ventasUltimosDias(dias); }
    @Transactional(readOnly = true) public List<PedidoRepository.TopVendedor> topVendedores(int dias, int limite) { return pedidos.topVendedores(dias, limite); }
    @Transactional(readOnly = true) public List<PedidoRepository.TopProducto> topProductos(int dias, int limite) { return pedidos.topProductos(dias, limite); }
    @Transactional(readOnly = true) public List<PedidoRepository.TopComprador> topCompradores(int dias, int limite) { return pedidos.topCompradores(dias, limite); }

}
