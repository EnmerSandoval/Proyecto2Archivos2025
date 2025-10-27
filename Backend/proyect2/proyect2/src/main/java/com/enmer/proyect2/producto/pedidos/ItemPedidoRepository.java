package com.enmer.proyect2.producto.pedidos;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemPedidoRepository extends JpaRepository<PedidoItem, Long> {
}
