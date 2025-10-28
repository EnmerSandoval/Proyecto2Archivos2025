package com.enmer.proyect2.producto.carrito.service;

import com.enmer.proyect2.auth.ProductoRepository;
import com.enmer.proyect2.auth.Usuario;
import com.enmer.proyect2.enums.EstadoCarrito;
import com.enmer.proyect2.enums.EstadoPedido;
import com.enmer.proyect2.producto.Producto;
import com.enmer.proyect2.producto.carrito.Carrito;
import com.enmer.proyect2.producto.carrito.CarritoRepository;
import com.enmer.proyect2.producto.carrito.Dto.CarritoDto;
import com.enmer.proyect2.producto.carrito.ItemCarrito;
import com.enmer.proyect2.producto.carrito.ItemCarritoRepository;
import com.enmer.proyect2.producto.pedidos.ItemPedidoRepository;
import com.enmer.proyect2.producto.pedidos.Pedido;
import com.enmer.proyect2.producto.pedidos.PedidoItem;
import com.enmer.proyect2.producto.pedidos.PedidoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.stream.Collectors;

import static org.springframework.http.HttpStatus.*;

@Service
@RequiredArgsConstructor
public class CarritoService {

    private final CarritoRepository carritoRepo;
    private final ItemCarritoRepository itemRepo;
    private final ProductoRepository productoRepo;
    private final PedidoRepository pedidoRepo;
    private final ItemPedidoRepository itemPedidoRepo;

    private final com.enmer.proyect2.producto.ProductoService common;

    private Carrito getOrCreateOpenCart(Usuario u) {
        return carritoRepo.findAbiertoByUsuario(u.getId())
                .orElseGet(() -> carritoRepo.save(
                        Carrito.builder()
                                .usuario(u)
                                .estado(EstadoCarrito.activo)
                                .build()
                ));
    }

    @Transactional(readOnly = true)
    public CarritoDto verCarrito() {
        var u = common.currentUserOrThrow();
        var c = carritoRepo.findAbiertoByUsuario(u.getId()).orElse(null);
        if (c == null) return new CarritoDto(null, java.util.List.of(), BigDecimal.ZERO);

        var items = c.getItems().stream().map(it ->
                new CarritoDto.ItemDto(
                        it.getId(),
                        it.getProducto().getId(),
                        it.getProducto().getNombre(),
                        it.getProducto().getImagenUrl(),
                        it.getCantidad(),
                        it.getPrecioUnitario(),
                        it.getPrecioUnitario().multiply(BigDecimal.valueOf(it.getCantidad()))
                )
        ).collect(Collectors.toList());

        var total = items.stream()
                .map(CarritoDto.ItemDto::subtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new CarritoDto(c.getId(), items, total);
    }

    @Transactional
    public CarritoDto agregar(Long productoId, int cantidad) {
        if (cantidad <= 0) throw new ResponseStatusException(BAD_REQUEST, "Cantidad inválida");

        var u = common.currentUserOrThrow();
        Producto p = productoRepo.findById(productoId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));

        if (p.getStock() == null || p.getStock() <= 0)
            throw new ResponseStatusException(BAD_REQUEST, "Sin stock");

        var c = getOrCreateOpenCart(u);

        var existing = itemRepo.findByCarrito_IdAndProducto_Id(c.getId(), p.getId()).orElse(null);
        if (existing == null) {
            existing = ItemCarrito.builder()
                    .carrito(c)
                    .producto(p)
                    .cantidad(Math.min(cantidad, p.getStock()))
                    .precioUnitario(p.getPrecio())
                    .build();
        } else {
            existing.setCantidad(Math.min(existing.getCantidad() + cantidad, p.getStock()));
        }
        itemRepo.save(existing);

        return verCarrito();
    }

    @Transactional
    public CarritoDto actualizarCantidad(Long itemId, int cantidad) {
        if (cantidad <= 0) throw new ResponseStatusException(BAD_REQUEST, "Cantidad inválida");

        var u = common.currentUserOrThrow();
        var c = getOrCreateOpenCart(u);

        var it = itemRepo.findById(itemId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));

        if (!it.getCarrito().getId().equals(c.getId()))
            throw new ResponseStatusException(FORBIDDEN);

        var stock = it.getProducto().getStock() == null ? 0 : it.getProducto().getStock();
        it.setCantidad(Math.min(cantidad, stock));
        itemRepo.save(it);

        return verCarrito();
    }

    @Transactional
    public CarritoDto eliminarItem(Long itemId) {
        var u = common.currentUserOrThrow();
        var c = getOrCreateOpenCart(u);

        var it = itemRepo.findById(itemId)
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND));

        if (!it.getCarrito().getId().equals(c.getId()))
            throw new ResponseStatusException(FORBIDDEN);

        itemRepo.delete(it);
        return verCarrito();
    }

    @Transactional
    public Long checkout(Long idDireccionEnvio) {
        var u = common.currentUserOrThrow();
        var c = carritoRepo.findAbiertoByUsuario(u.getId())
                .orElseThrow(() -> new ResponseStatusException(BAD_REQUEST, "Carrito vacío"));

        if (c.getItems().isEmpty())
            throw new ResponseStatusException(BAD_REQUEST, "Carrito vacío");

        var pedido = Pedido.builder()
                .comprador(u)
                .estado(EstadoPedido.creado)
                .idDireccionEnvio(idDireccionEnvio)
                .build();
        pedidoRepo.save(pedido);

        BigDecimal total = BigDecimal.ZERO;

        for (var it : c.getItems()) {
            var prod = it.getProducto();
            int nuevoStock = (prod.getStock() == null ? 0 : prod.getStock()) - it.getCantidad();
            if (nuevoStock < 0)
                throw new ResponseStatusException(BAD_REQUEST, "Sin stock: " + prod.getNombre());

            prod.setStock(nuevoStock);

            var ip = PedidoItem.builder()
                    .pedido(pedido)
                    .producto(prod)
                    .cantidad(it.getCantidad())
                    .precioUnitario(it.getPrecioUnitario())
                    .build();
            itemPedidoRepo.save(ip);

            total = total.add(it.getPrecioUnitario()
                    .multiply(BigDecimal.valueOf(it.getCantidad())));
        }

        pedido.setMontoTotal(total);
        pedidoRepo.save(pedido);

        c.setEstado(EstadoCarrito.borrado);
        carritoRepo.save(c);

        return pedido.getId();
    }
}
