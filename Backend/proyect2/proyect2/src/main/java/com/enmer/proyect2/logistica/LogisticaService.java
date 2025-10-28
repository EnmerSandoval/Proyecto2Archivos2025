package com.enmer.proyect2.logistica;

import com.enmer.proyect2.logistica.dto.PedidoView;
import com.enmer.proyect2.logistica.repo.PedidoLogisticaReadRepository;
import com.enmer.proyect2.logistica.repo.PedidoLogisticaWriteRepository;
import com.enmer.proyect2.producto.pedidos.Pedido;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class LogisticaService {
    private final PedidoLogisticaReadRepository readRepo;
    private final PedidoLogisticaWriteRepository writeRepo;

    @Transactional(readOnly = true)
    public Page<PedidoView> listar(String estado, Pageable pageable) {
        return readRepo.findByEstado(estado, pageable).map(this::toView);
    }

    @Transactional
    public void enRuta(Long id) {
        if (writeRepo.marcarEnRuta(id) == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se pudo pasar a EN_RUTA (estado inválido o no existe)");
        }
    }

    @Transactional
    public void entregado(Long id) {
        if (writeRepo.marcarEntregado(id) == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se pudo marcar ENTREGADO (estado inválido o no existe)");
        }
    }

    @Transactional
    public void reprogramar(Long id, Instant nueva) {
        if (nueva == null || nueva.isBefore(Instant.now()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Fecha prometida inválida");
        if (writeRepo.reprogramarPromesa(id, nueva) == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se pudo reprogramar (estado/ID inválido)");
        }
    }

    private PedidoView toView(Pedido p) {
        return new PedidoView(
                p.getId(),
                p.getComprador().getId(),
                p.getEstado().name(),
                p.getRealizadoEn(),
                p.getFechaPrometidaEntrega(),
                p.getFechaEntrega(),
                p.getDireccionEnvio(),
                p.getMontoTotal()
        );
    }
}
