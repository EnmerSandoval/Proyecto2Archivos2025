package com.enmer.proyect2.producto;

import com.enmer.proyect2.auth.CategoriaRepository;
import com.enmer.proyect2.auth.ProductoRepository;
import com.enmer.proyect2.auth.UserRepository;
import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.dto.CrearProductoRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.Instant;

import static org.springframework.http.HttpStatus.*;

@Service
@RequiredArgsConstructor
public class ProductoService {
    private final ProductoRepository productoRepo;
    private final CategoriaRepository categoriaRepo;
    private final UserRepository userRepo;

    private Usuario currentUserOrThrow() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) throw new ResponseStatusException(UNAUTHORIZED);
        String email = auth.getName();
        return userRepo.findByEmail(email).orElseThrow(() -> new ResponseStatusException(UNAUTHORIZED));
    }

    public Producto crearProducto(CrearProductoRequest req) {
        Usuario vendedor = currentUserOrThrow();
        var categoria = categoriaRepo.findById(req.idCategoria())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Categoría no existe"));

        var p = Producto.builder()
                .vendedor(vendedor)
                .nombre(req.nombre())
                .descripcion(req.descripcion())
                .imagenUrl(req.imagenUrl())
                .precio(req.precio())
                .stock(req.stock())
                .condicion(req.condicion())
                .categoria(categoria)
                .estado(EstadoProducto.pendiente)
                .build();

        return productoRepo.save(p);
    }

    public Page<Producto> catalogo(Long categoriaId, String q, Pageable pageable) {
        String term = (q == null || q.isBlank()) ? null : q.trim();
        return productoRepo.buscarCatalogo(EstadoProducto.aprobado, categoriaId, term, pageable);
    }

    public Page<Producto> pendientes(Pageable pageable) {
        return productoRepo.findByEstado(EstadoProducto.pendiente, pageable);
    }

    public Producto aprobar(Long idProducto) {
        var moderador = currentUserOrThrow();
        var p = productoRepo.findById(idProducto)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));
        p.setEstado(EstadoProducto.aprobado);
        p.setMotivoRechazo(null);
        p.setRevisadoPor(moderador);
        p.setRevisadoEn(Instant.now());
        return productoRepo.save(p);
    }

    public Producto rechazar(Long idProducto, String motivo) {
        if (motivo == null || motivo.isBlank())
            throw new ResponseStatusException(BAD_REQUEST, "Motivo es requerido");

        var moderador = currentUserOrThrow();
        var p = productoRepo.findById(idProducto)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));
        p.setEstado(EstadoProducto.rechazado);
        p.setMotivoRechazo(motivo);
        p.setRevisadoPor(moderador);
        p.setRevisadoEn(Instant.now());
        return productoRepo.save(p);
    }

    public Page<Producto> misProductos(String q, EstadoProducto estado, Pageable pageable) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        Usuario u = userRepo.findByEmail(email).orElseThrow(() -> new IllegalStateException("Usuario no encontrado"));
        String term = (q == null || q.isBlank()) ? null : q.trim();
        return productoRepo.buscarPorVendedor(u.getId(), estado, term, pageable);
    }

}
