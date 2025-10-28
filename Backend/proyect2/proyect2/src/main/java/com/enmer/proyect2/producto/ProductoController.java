package com.enmer.proyect2.producto;

import com.enmer.proyect2.auth.ProductoRepository;
import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.dto.*;
import com.enmer.proyect2.producto.pedidos.PedidoRepository;
import com.enmer.proyect2.producto.resena.ResenaProducto;
import com.enmer.proyect2.producto.resena.ResenaRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.util.List;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@RestController
@RequiredArgsConstructor
public class ProductoController {
    private final ProductoService service;
    private final ProductoRepository productoRepo;
    private final PedidoRepository pedidoRepo;
    private final ResenaRepository resenaRepo;

    @GetMapping("/api/catalogo")
    public Page<ProductoResumenDto> catalogo(
            @RequestParam(required = false) Long categoriaId,
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size
    ) {
        var pageable = PageRequest.of(page, Math.min(size, 50), Sort.by("id").descending());
        return service.catalogo(categoriaId, q, pageable)
                .map(p -> new ProductoResumenDto(
                        p.getId(), p.getNombre(), p.getPrecio(), p.getStock(),
                        p.getCondicion().name(), p.getImagenUrl(),
                        p.getCategoria().getId(), p.getEstado().name(), p.getMotivoRechazo()
                ));
    }

    @PostMapping("/api/productos")
    public ResponseEntity<Void> crear(@RequestBody @Valid CrearProductoRequest req){
        var creado = service.crearProducto(req);
        return ResponseEntity.created(URI.create("/api/productos/" + creado.getId())).build();
    }

    @GetMapping("/api/mis-productos")
    public Page<ProductoResumenDto> misProductos(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) EstadoProducto estado,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size
    ) {
        Pageable pageable = PageRequest.of(page, Math.min(size, 50), Sort.by("id").descending());
        return service.misProductos(q, estado, pageable)
                .map(p -> new ProductoResumenDto(
                        p.getId(),
                        p.getNombre(),
                        p.getPrecio(),
                        p.getStock(),
                        p.getCondicion().name(),
                        p.getImagenUrl(),
                        p.getCategoria().getId(),
                        p.getEstado().name(),
                        p.getMotivoRechazo()
                ));
    }

    @GetMapping("/api/productos/{id}")
    public ResponseEntity<ProductoDetalleDto> detalle(@PathVariable Long id) {
        return ResponseEntity.ok(service.obtenerDetallePropietario(id));
    }

    @PutMapping("/api/productos/{id}")
    public ResponseEntity<Void> editar(@PathVariable Long id, @RequestBody @Valid EditarProductoRequest req) {
        service.editarProducto(id, req);
        return ResponseEntity.noContent().build();
    }

    public Producto buscarPorIdOr404(Long id) {
        return productoRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));
    }

    @GetMapping("/api/productos/{id}/resenas")
    public List<ResenaDto> resenasDeProducto(@PathVariable Long id) {
        return resenaRepo.findDtosByProductoId(id);
    }

    @PostMapping("/api/productos/{id}/resenas")
    public ResenaDto crearResena(@PathVariable Long id,
        @RequestBody CrearResenaRequest req) {
        if (req.calificacion() == null || req.calificacion() < 1 || req.calificacion() > 5)
            throw new ResponseStatusException(BAD_REQUEST, "Calificación 1..5 requerida");

        var u = service.currentUserOrThrow();
        var p = buscarPorIdOr404(id);

        if (!pedidoRepo.hasDeliveredPurchase(u.getId(), p.getId()))
            throw new ResponseStatusException(BAD_REQUEST, "Solo puedes calificar productos comprados y entregados.");

        if (resenaRepo.existsByCompradorIdAndProductoId(u.getId(), p.getId()))
            throw new ResponseStatusException(BAD_REQUEST, "Ya calificaste este producto.");

        var r = resenaRepo.save(
                ResenaProducto.builder()
                        .producto(p)
                        .comprador(u)
                        .calificacion(req.calificacion().shortValue())
                        .comentario(req.comentario())
                        .build()
        );

        return new ResenaDto(
                r.getId(), r.getProducto().getId(), r.getComprador().getId(),
                (int) r.getCalificacion(), r.getComentario(), r.getCreadoEn(), r.getComprador().getNombre()
        );
    }


}
