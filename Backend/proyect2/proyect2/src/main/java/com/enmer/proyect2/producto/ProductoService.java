package com.enmer.proyect2.producto;

import com.enmer.proyect2.auth.CategoriaRepository;
import com.enmer.proyect2.auth.ProductoRepository;
import com.enmer.proyect2.auth.UserRepository;
import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.dto.*;
import com.enmer.proyect2.producto.pedidos.PedidoRepository;
import com.enmer.proyect2.producto.resena.ResenaProducto;
import com.enmer.proyect2.producto.resena.ResenaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

import static com.enmer.proyect2.producto.ProductoMapper.toDetalle;
import static org.springframework.http.HttpStatus.*;

@Service
@RequiredArgsConstructor
public class ProductoService {

    private final ProductoRepository productoRepo;
    private final CategoriaRepository categoriaRepo;
    private final UserRepository userRepo;
    private final ResenaRepository resenaRepo;
    private final PedidoRepository pedidoRepo;

    public Usuario currentUserOrThrow() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new ResponseStatusException(UNAUTHORIZED);
        }
        String name = auth.getName();
        if (name == null || "anonymousUser".equalsIgnoreCase(name)) {
            throw new ResponseStatusException(UNAUTHORIZED);
        }
        return userRepo.findByEmail(name)
                .orElseThrow(() -> new ResponseStatusException(UNAUTHORIZED, "Usuario no encontrado"));
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
        String pattern = (q == null || q.isBlank()) ? null : "%" + q.trim().toLowerCase() + "%";
        return productoRepo.buscarCatalogo(EstadoProducto.aprobado, categoriaId, pattern, pageable);
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
        if (motivo == null || motivo.isBlank()) {
            throw new ResponseStatusException(BAD_REQUEST, "Motivo es requerido");
        }
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
        Usuario u = currentUserOrThrow();

        boolean hasQ = q != null && !q.isBlank();
        if (!hasQ && estado == null) {
            return productoRepo.findByVendedorId(u.getId(), pageable);
        }
        if (!hasQ) {
            return productoRepo.findByVendedorIdAndEstado(u.getId(), estado, pageable);
        }

        String pattern = "%" + q.trim().toLowerCase() + "%";
        if (estado == null) {
            return productoRepo.buscarPorVendedorConBusqueda(u.getId(), pattern, pageable);
        }
        return productoRepo.buscarPorVendedorConBusquedaYEstado(u.getId(), estado, pattern, pageable);
    }

    public ProductoDetalleDto obtenerDetallePropietario(Long idProducto) {
        var u = currentUserOrThrow();
        var p = productoRepo.findById(idProducto)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));
        boolean esDuenio = p.getVendedor().getId().equals(u.getId());
        boolean esAdmin = u.getRol() != null && u.getRol().name().equalsIgnoreCase("admin");
        if (!esDuenio && !esAdmin) throw new AccessDeniedException("No autorizado");
        return toDetalle(p);
    }

    public void editarProducto(Long idProducto, EditarProductoRequest req) {
        var u = currentUserOrThrow();
        var p = productoRepo.findById(idProducto)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));

        boolean esDuenio = p.getVendedor().getId().equals(u.getId());
        boolean esAdmin = u.getRol() != null && u.getRol().name().equalsIgnoreCase("admin");
        if (!esDuenio && !esAdmin) throw new AccessDeniedException("No autorizado");

        var categoria = categoriaRepo.findById(req.idCategoria())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Categoría no existe"));

        p.setNombre(req.nombre());
        p.setDescripcion(req.descripcion());
        p.setImagenUrl(req.imagenUrl());
        p.setPrecio(req.precio());
        p.setStock(req.stock());
        p.setCondicion(req.condicion());
        p.setCategoria(categoria);

        productoRepo.save(p);
    }

    public Producto buscarPorIdOr404(Long id) {
        return productoRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));
    }

    public List<ResenaDto> resenasDeProducto(Long idProducto) {
        return resenaRepo.findDtosByProductoId(idProducto);
    }


    public ResenaProducto crearResena(Long idProducto, CrearResenaRequest req) {
        if (req.calificacion() == null || req.calificacion() < 1 || req.calificacion() > 5)
            throw new ResponseStatusException(BAD_REQUEST, "Calificación 1..5 requerida");

        var u = currentUserOrThrow();
        var p = buscarPorIdOr404(idProducto);

        // OPCIONAL: comenta/borra esta línea si también quieres permitir reseñas repetidas
        if (resenaRepo.existsByCompradorIdAndProductoId(u.getId(), p.getId()))
            throw new ResponseStatusException(BAD_REQUEST, "Ya calificaste este producto.");

        var r = ResenaProducto.builder()
                .producto(p)
                .comprador(u)
                .calificacion(req.calificacion().shortValue())
                .comentario(req.comentario())
                .build();

        return resenaRepo.save(r);
    }


}
