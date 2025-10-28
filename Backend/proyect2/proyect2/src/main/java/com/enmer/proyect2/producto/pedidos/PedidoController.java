package com.enmer.proyect2.producto.pedidos;

import com.enmer.proyect2.producto.dto.PedidoDetalleDto;
import com.enmer.proyect2.producto.dto.PedidoListDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/pedidos")
public class PedidoController {

    private final PedidoRepository pedidoRepo;
    private final com.enmer.proyect2.producto.ProductoService common; // para currentUserOrThrow()

    @GetMapping
    @Transactional(readOnly = true)
    public Page<PedidoListDto> misPedidos(@RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "12") int size) {
        var u = common.currentUserOrThrow();
        return pedidoRepo
                .findByCompradorIdOrderByIdDesc(u.getId(), PageRequest.of(page, Math.min(size, 50)))
                .map(p -> new PedidoListDto(
                        p.getId(),
                        p.getEstado().name(),
                        p.getMontoTotal(),
                        p.getRealizadoEn()
                ));
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public PedidoDetalleDto detalle(@PathVariable Long id) {
        var u = common.currentUserOrThrow();
        var p = pedidoRepo.findByIdAndCompradorId(id, u.getId())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));

        var items = p.getItems().stream().map(ip ->
                new PedidoDetalleDto.ItemDto(
                        ip.getProducto().getId(),
                        ip.getProducto().getNombre(),
                        ip.getCantidad(),
                        ip.getPrecioUnitario(),
                        ip.getPrecioUnitario().multiply(java.math.BigDecimal.valueOf(ip.getCantidad())),
                        ip.getProducto().getImagenUrl()
                )
        ).toList();

        return new PedidoDetalleDto(
                p.getId(),
                p.getEstado().name(),
                p.getMontoTotal(),
                p.getRealizadoEn(),
                p.getDireccionEnvio(),
                items
        );
    }
}
