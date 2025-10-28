package com.enmer.proyect2.producto.resena;

import com.enmer.proyect2.producto.dto.ResenaDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ResenaRepository extends JpaRepository<ResenaProducto, Long> {

    List<ResenaProducto> findAllByProducto_IdOrderByCreadoEnDesc(Long productoId);

    Page<ResenaProducto> findAllByProducto_Id(Long productoId, Pageable pageable);

    boolean existsByComprador_IdAndProducto_Id(Long compradorId, Long productoId);

    @Query("SELECT AVG(r.calificacion) FROM ResenaProducto r WHERE r.producto.id = :pid")
    Double avgByProducto(@Param("pid") Long productoId);

    @Query("""
        SELECT r FROM ResenaProducto r
        WHERE r.producto.id = :pid
        ORDER BY r.creadoEn DESC
    """)
    List<ResenaProducto> findByProducto(@Param("pid") Long productoId);

    boolean existsByCompradorIdAndProductoId(Long compradorId, Long productoId);

    @Query("""
  select new com.enmer.proyect2.producto.dto.ResenaDto(
    r.id,
    r.producto.id,
    r.comprador.id,
    cast(r.calificacion as integer),
    r.comentario,
    r.creadoEn,
    r.comprador.nombre
  )
  from ResenaProducto r
  where r.producto.id = :idProducto
  order by r.creadoEn desc
""")
    List<ResenaDto> findDtosByProductoId(@Param("idProducto") Long idProducto);

}
