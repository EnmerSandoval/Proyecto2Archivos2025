package com.enmer.proyect2.producto;

import com.enmer.proyect2.enums.EstadoProducto;
import com.enmer.proyect2.producto.dto.CrearProductoRequest;
import com.enmer.proyect2.producto.dto.ProductoResumenDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
@RequiredArgsConstructor
public class ProductoController {
    private final ProductoService service;

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
                        p.getCategoria().getId()
                ));
    }

    @PostMapping("/api/productos")
    public ResponseEntity<Void> crear(@RequestBody @Valid CrearProductoRequest req){
        var creado = service.crearProducto(req);
        return ResponseEntity.created(URI.create("/api/productos/" + creado.getId())).build();
    }
}
