package com.enmer.proyect2.moderador;

import com.enmer.proyect2.auth.UserRepository;
import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.moderador.dto.ProductoView;
import com.enmer.proyect2.moderador.repo.ProductoModeracionReadRepository;
import com.enmer.proyect2.moderador.repo.ProductoModeracionWriteRepository;
import com.enmer.proyect2.producto.Producto;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class ModeracionService {

    private final EntityManager em;
    private final ProductoModeracionWriteRepository writeRepo;
    private final ProductoModeracionReadRepository readRepo;
    private final UserRepository usuarioRepo;

    @Transactional(readOnly = true)
    public Page<ProductoView> listar(String estado, Pageable pageable) {
        EstadoProducto filtro = parseEstadoOrNull(estado);
        Page<Producto> page = (filtro == null)
                ? readRepo.findAllByOrderByIdDesc(pageable)
                : readRepo.findByEstadoOrderByIdDesc(filtro, pageable);

        return page.map(this::toView);
    }

    @Transactional
    public void aprobar(Long productoId, Authentication auth) {
        Long modId = authUserId(auth);
        Usuario moderadorRef = em.getReference(Usuario.class, modId);

        int rows = writeRepo.aprobar(
                productoId,
                moderadorRef,
                EstadoProducto.aprobado,
                EstadoProducto.pendiente
        );
        if (rows == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se pudo aprobar (estado inválido o no existe)");
        }
    }

    @Transactional
    public void rechazar(Long productoId, String motivo, Authentication auth) {
        if (motivo == null || motivo.trim().length() < 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Motivo demasiado corto");
        }
        Long modId = authUserId(auth);
        Usuario moderadorRef = em.getReference(Usuario.class, modId);

        int rows = writeRepo.rechazar(
                productoId,
                motivo.trim(),
                moderadorRef,
                EstadoProducto.rechazado,
                EstadoProducto.pendiente
        );
        if (rows == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se pudo rechazar (estado inválido o no existe)");
        }
    }

    private EstadoProducto parseEstadoOrNull(String raw) {
        if (raw == null || raw.isBlank()) return null;
        for (EstadoProducto e : EstadoProducto.values()) {
            if (e.name().equalsIgnoreCase(raw.trim())) return e;
        }
        throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Estado inválido. Usa uno de: " + java.util.Arrays.toString(EstadoProducto.values())
        );
    }

    private ProductoView toView(Producto p) {
        Long revisadoPorId = (p.getRevisadoPor() != null) ? p.getRevisadoPor().getId() : null;
        Long vendedorId    = (p.getVendedor()   != null) ? p.getVendedor().getId()     : null;

        return new ProductoView(
                p.getId(),
                p.getNombre(),
                p.getPrecio(),
                p.getEstado().name(),
                p.getMotivoRechazo(),
                p.getRevisadoEn(),
                revisadoPorId,
                vendedorId
        );
    }

    private Long authUserId(Authentication auth) {
        String email = auth.getName();
        return usuarioRepo.findByEmail(email)
                .map(Usuario::getId)
                .orElseThrow(() ->
                        new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado: " + email)
                );
    }


}
