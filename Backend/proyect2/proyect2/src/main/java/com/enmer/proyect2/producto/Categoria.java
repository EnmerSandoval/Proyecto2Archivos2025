package com.enmer.proyect2.producto;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "categorias", schema = "ecommerce_gt")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Categoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre", nullable = false, unique = true, length = 60)
    private String nombre;
}
