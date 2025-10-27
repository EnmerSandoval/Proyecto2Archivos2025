package com.enmer.proyect2.producto;

import com.enmer.proyect2.producto.dto.ProductoDetalleDto;

public class ProductoMapper {
    public static ProductoDetalleDto toDetalle(Producto p) {
        return new ProductoDetalleDto(
                p.getId(),
                p.getNombre(),
                p.getDescripcion(),
                p.getImagenUrl(),
                p.getPrecio(),
                p.getStock(),
                p.getCondicion(),
                p.getCategoria().getId(),
                p.getEstado(),
                p.getCreadoEn(),
                p.getFechaActualizada()
        );
    }
}
