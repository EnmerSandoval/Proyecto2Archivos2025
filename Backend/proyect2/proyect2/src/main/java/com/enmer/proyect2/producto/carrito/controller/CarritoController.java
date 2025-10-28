package com.enmer.proyect2.producto.carrito.controller;


import com.enmer.proyect2.producto.carrito.Dto.AddItemRequest;
import com.enmer.proyect2.producto.carrito.Dto.CarritoDto;
import com.enmer.proyect2.producto.carrito.Dto.CheckoutRequest;
import com.enmer.proyect2.producto.carrito.Dto.UpdateCantidadRequest;
import com.enmer.proyect2.producto.carrito.service.CarritoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/carrito")
public class CarritoController {
    private final CarritoService service;

    @GetMapping
    public CarritoDto get() { return service.verCarrito(); }

    @PostMapping("/items")
    public CarritoDto add(@RequestBody AddItemRequest req) {
        return service.agregar(req.productoId(), req.cantidad() == null ? 1 : req.cantidad());
    }

    @PatchMapping("/items/{id}")
    public CarritoDto update(@PathVariable Long id, @RequestBody UpdateCantidadRequest req) {
        return service.actualizarCantidad(id, req.cantidad());
    }

    @DeleteMapping("/items/{id}")
    public CarritoDto remove(@PathVariable Long id) {
        return service.eliminarItem(id);
    }

    @PostMapping("/checkout")
    public ResponseEntity<Void> checkout(@RequestBody CheckoutRequest req) {
        Long id = service.checkout(req.direccionEnvio());
        return ResponseEntity.created(URI.create("/api/pedidos/" + id)).build();
    }
}
