--
-- PostgreSQL database dump
--

-- Dumped from database version 16.10
-- Dumped by pg_dump version 17.5

-- Started on 2025-10-28 14:14:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 36007)
-- Name: ecommerce_gt; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ecommerce_gt;


ALTER SCHEMA ecommerce_gt OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 36008)
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA ecommerce_gt;


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 929 (class 1247 OID 36124)
-- Name: condicion_producto; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.condicion_producto AS ENUM (
    'nuevo',
    'usado'
);


ALTER TYPE ecommerce_gt.condicion_producto OWNER TO postgres;

--
-- TOC entry 947 (class 1247 OID 36170)
-- Name: decision_moderacion; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.decision_moderacion AS ENUM (
    'aprobado',
    'rechazado'
);


ALTER TYPE ecommerce_gt.decision_moderacion OWNER TO postgres;

--
-- TOC entry 935 (class 1247 OID 36140)
-- Name: estado_carrito; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.estado_carrito AS ENUM (
    'activo',
    'pagado',
    'borrado'
);


ALTER TYPE ecommerce_gt.estado_carrito OWNER TO postgres;

--
-- TOC entry 941 (class 1247 OID 36154)
-- Name: estado_pago; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.estado_pago AS ENUM (
    'autorizado',
    'capturado',
    'fallido',
    'reembolsado'
);


ALTER TYPE ecommerce_gt.estado_pago OWNER TO postgres;

--
-- TOC entry 938 (class 1247 OID 36148)
-- Name: estado_pedido; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.estado_pedido AS ENUM (
    'en_curso',
    'entregado'
);


ALTER TYPE ecommerce_gt.estado_pedido OWNER TO postgres;

--
-- TOC entry 932 (class 1247 OID 36130)
-- Name: estado_producto; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.estado_producto AS ENUM (
    'pendiente',
    'aprobado',
    'rechazado',
    'suspendido'
);


ALTER TYPE ecommerce_gt.estado_producto OWNER TO postgres;

--
-- TOC entry 944 (class 1247 OID 36164)
-- Name: estado_sancion; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.estado_sancion AS ENUM (
    'activo',
    'levantado'
);


ALTER TYPE ecommerce_gt.estado_sancion OWNER TO postgres;

--
-- TOC entry 926 (class 1247 OID 36114)
-- Name: rol_usuario; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.rol_usuario AS ENUM (
    'comun',
    'moderador',
    'logistica',
    'admin'
);


ALTER TYPE ecommerce_gt.rol_usuario OWNER TO postgres;

--
-- TOC entry 950 (class 1247 OID 36176)
-- Name: tipo_notificacion; Type: TYPE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TYPE ecommerce_gt.tipo_notificacion AS ENUM (
    'cambio_estado_pedido',
    'resultado_moderacion',
    'otro'
);


ALTER TYPE ecommerce_gt.tipo_notificacion OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 36500)
-- Name: producto_vuelve_pendiente(); Type: FUNCTION; Schema: ecommerce_gt; Owner: postgres
--

CREATE FUNCTION ecommerce_gt.producto_vuelve_pendiente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (OLD.estado = 'aprobado') AND (
       COALESCE(NEW.nombre,'')          IS DISTINCT FROM COALESCE(OLD.nombre,'') OR
       COALESCE(NEW.descripcion,'')     IS DISTINCT FROM COALESCE(OLD.descripcion,'') OR
       COALESCE(NEW.imagen_url,'')      IS DISTINCT FROM COALESCE(OLD.imagen_url,'') OR
       COALESCE(NEW.precio,0)           IS DISTINCT FROM COALESCE(OLD.precio,0) OR
       COALESCE(NEW.stock,0)            IS DISTINCT FROM COALESCE(OLD.stock,0) OR
       COALESCE(NEW.condicion::text,'') IS DISTINCT FROM COALESCE(OLD.condicion::text,'') OR
       COALESCE(NEW.id_categoria,0)     IS DISTINCT FROM COALESCE(OLD.id_categoria,0)
     ) THEN
     NEW.estado := 'pendiente';
     NEW.revisado_por := NULL;
     NEW.revisado_en := NULL;
     NEW.motivo_rechazo := NULL;
  END IF;
  RETURN NEW;
END $$;


ALTER FUNCTION ecommerce_gt.producto_vuelve_pendiente() OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 36501)
-- Name: refrescar_total_pedido(bigint); Type: FUNCTION; Schema: ecommerce_gt; Owner: postgres
--

CREATE FUNCTION ecommerce_gt.refrescar_total_pedido(p_pedido bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE ecommerce_gt.pedidos p
     SET monto_total = COALESCE((SELECT SUM(total_linea) FROM ecommerce_gt.items_pedido ip WHERE ip.id_pedido = p_pedido), 0)
   WHERE p.id = p_pedido;
END $$;


ALTER FUNCTION ecommerce_gt.refrescar_total_pedido(p_pedido bigint) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 36499)
-- Name: set_fecha_actualizada(); Type: FUNCTION; Schema: ecommerce_gt; Owner: postgres
--

CREATE FUNCTION ecommerce_gt.set_fecha_actualizada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.fecha_actualizada := now();
  RETURN NEW;
END $$;


ALTER FUNCTION ecommerce_gt.set_fecha_actualizada() OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 36502)
-- Name: trigger_refrescar_total_pedido(); Type: FUNCTION; Schema: ecommerce_gt; Owner: postgres
--

CREATE FUNCTION ecommerce_gt.trigger_refrescar_total_pedido() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_pedido BIGINT;
BEGIN
  v_pedido := COALESCE(NEW.id_pedido, OLD.id_pedido);
  PERFORM ecommerce_gt.refrescar_total_pedido(v_pedido);
  RETURN COALESCE(NEW, OLD);
END $$;


ALTER FUNCTION ecommerce_gt.trigger_refrescar_total_pedido() OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 36503)
-- Name: validar_elegibilidad_resena(); Type: FUNCTION; Schema: ecommerce_gt; Owner: postgres
--

CREATE FUNCTION ecommerce_gt.validar_elegibilidad_resena() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM 1
  FROM ecommerce_gt.pedidos p
  JOIN ecommerce_gt.items_pedido ip ON ip.id_pedido = p.id
  WHERE p.id = NEW.id_pedido
    AND p.id_comprador = NEW.id_comprador
    AND ip.id_producto = NEW.id_producto
    AND p.estado = 'entregado'
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo puedes calificar productos comprados y entregados.';
  END IF;

  RETURN NEW;
END $$;


ALTER FUNCTION ecommerce_gt.validar_elegibilidad_resena() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 244 (class 1259 OID 36479)
-- Name: actualizaciones_entrega; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.actualizaciones_entrega (
    id bigint NOT NULL,
    id_pedido bigint NOT NULL,
    id_usuario_logistica bigint NOT NULL,
    fecha_anterior date,
    fecha_nueva date NOT NULL,
    nota text,
    cambiado_en timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ecommerce_gt.actualizaciones_entrega OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 36478)
-- Name: actualizaciones_entrega_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.actualizaciones_entrega_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.actualizaciones_entrega_id_seq OWNER TO postgres;

--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 243
-- Name: actualizaciones_entrega_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.actualizaciones_entrega_id_seq OWNED BY ecommerce_gt.actualizaciones_entrega.id;


--
-- TOC entry 226 (class 1259 OID 36262)
-- Name: carritos; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.carritos (
    id bigint NOT NULL,
    id_usuario bigint NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizada timestamp with time zone DEFAULT now() NOT NULL,
    estado character varying(20) DEFAULT 'activo'::character varying NOT NULL
);


ALTER TABLE ecommerce_gt.carritos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 36261)
-- Name: carritos_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.carritos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.carritos_id_seq OWNER TO postgres;

--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 225
-- Name: carritos_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.carritos_id_seq OWNED BY ecommerce_gt.carritos.id;


--
-- TOC entry 222 (class 1259 OID 36220)
-- Name: categorias; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.categorias (
    id bigint NOT NULL,
    nombre character varying(60) NOT NULL
);


ALTER TABLE ecommerce_gt.categorias OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 36219)
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.categorias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.categorias_id_seq OWNER TO postgres;

--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.categorias_id_seq OWNED BY ecommerce_gt.categorias.id;


--
-- TOC entry 242 (class 1259 OID 36460)
-- Name: historial_estado_pedido; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.historial_estado_pedido (
    id bigint NOT NULL,
    id_pedido bigint NOT NULL,
    estado_origen ecommerce_gt.estado_pedido,
    estado_destino ecommerce_gt.estado_pedido NOT NULL,
    cambiado_por bigint,
    cambiado_en timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ecommerce_gt.historial_estado_pedido OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 36459)
-- Name: historial_estado_pedido_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.historial_estado_pedido_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.historial_estado_pedido_id_seq OWNER TO postgres;

--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 241
-- Name: historial_estado_pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.historial_estado_pedido_id_seq OWNED BY ecommerce_gt.historial_estado_pedido.id;


--
-- TOC entry 228 (class 1259 OID 36278)
-- Name: items_carrito; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.items_carrito (
    id bigint NOT NULL,
    id_carrito bigint NOT NULL,
    id_producto bigint NOT NULL,
    cantidad integer NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT items_carrito_cantidad_check CHECK ((cantidad >= 1)),
    CONSTRAINT items_carrito_precio_unitario_check CHECK ((precio_unitario > (0)::numeric))
);


ALTER TABLE ecommerce_gt.items_carrito OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 36277)
-- Name: items_carrito_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.items_carrito_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.items_carrito_id_seq OWNER TO postgres;

--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 227
-- Name: items_carrito_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.items_carrito_id_seq OWNED BY ecommerce_gt.items_carrito.id;


--
-- TOC entry 232 (class 1259 OID 36345)
-- Name: items_pedido; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.items_pedido (
    id bigint NOT NULL,
    id_pedido bigint NOT NULL,
    id_producto bigint NOT NULL,
    id_vendedor bigint NOT NULL,
    cantidad integer NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    total_linea numeric(14,2) GENERATED ALWAYS AS (((cantidad)::numeric * precio_unitario)) STORED,
    ganancia_vendedor numeric(14,2) GENERATED ALWAYS AS ((((cantidad)::numeric * precio_unitario) * 0.95)) STORED,
    comision_plataforma numeric(14,2) GENERATED ALWAYS AS ((((cantidad)::numeric * precio_unitario) * 0.05)) STORED,
    CONSTRAINT items_pedido_cantidad_check CHECK ((cantidad >= 1)),
    CONSTRAINT items_pedido_precio_unitario_check CHECK ((precio_unitario > (0)::numeric))
);


ALTER TABLE ecommerce_gt.items_pedido OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 36344)
-- Name: items_pedido_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.items_pedido_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.items_pedido_id_seq OWNER TO postgres;

--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 231
-- Name: items_pedido_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.items_pedido_id_seq OWNED BY ecommerce_gt.items_pedido.id;


--
-- TOC entry 240 (class 1259 OID 36443)
-- Name: notificaciones; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.notificaciones (
    id bigint NOT NULL,
    id_usuario bigint,
    tipo ecommerce_gt.tipo_notificacion NOT NULL,
    asunto text NOT NULL,
    cuerpo text NOT NULL,
    meta jsonb,
    enviado_en timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ecommerce_gt.notificaciones OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 36442)
-- Name: notificaciones_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.notificaciones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.notificaciones_id_seq OWNER TO postgres;

--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 239
-- Name: notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.notificaciones_id_seq OWNED BY ecommerce_gt.notificaciones.id;


--
-- TOC entry 236 (class 1259 OID 36393)
-- Name: pagos; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.pagos (
    id bigint NOT NULL,
    id_pedido bigint NOT NULL,
    id_tarjeta bigint,
    monto numeric(14,2) NOT NULL,
    estado ecommerce_gt.estado_pago DEFAULT 'capturado'::ecommerce_gt.estado_pago NOT NULL,
    id_proveedor character varying(120),
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT pagos_monto_check CHECK ((monto >= (0)::numeric))
);


ALTER TABLE ecommerce_gt.pagos OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 36392)
-- Name: pagos_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.pagos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.pagos_id_seq OWNER TO postgres;

--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 235
-- Name: pagos_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.pagos_id_seq OWNED BY ecommerce_gt.pagos.id;


--
-- TOC entry 230 (class 1259 OID 36320)
-- Name: pedidos; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.pedidos (
    id bigint NOT NULL,
    id_comprador bigint NOT NULL,
    estado character varying(20) DEFAULT 'en_curso'::character varying NOT NULL,
    realizado_en timestamp with time zone DEFAULT now() NOT NULL,
    fecha_prometida_entrega date DEFAULT ((now() + '5 days'::interval))::date NOT NULL,
    fecha_entrega date,
    monto_total numeric(14,2) DEFAULT 0 NOT NULL,
    direccion_envio character varying(255) NOT NULL,
    CONSTRAINT pedidos_monto_total_check CHECK ((monto_total >= (0)::numeric))
);


ALTER TABLE ecommerce_gt.pedidos OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 36319)
-- Name: pedidos_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.pedidos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.pedidos_id_seq OWNER TO postgres;

--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 229
-- Name: pedidos_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.pedidos_id_seq OWNED BY ecommerce_gt.pedidos.id;


--
-- TOC entry 224 (class 1259 OID 36229)
-- Name: productos; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.productos (
    id bigint NOT NULL,
    id_vendedor bigint NOT NULL,
    nombre character varying(160) NOT NULL,
    descripcion text NOT NULL,
    imagen_url text,
    precio numeric(12,2) NOT NULL,
    stock integer NOT NULL,
    condicion ecommerce_gt.condicion_producto NOT NULL,
    id_categoria bigint NOT NULL,
    estado ecommerce_gt.estado_producto DEFAULT 'pendiente'::ecommerce_gt.estado_producto NOT NULL,
    revisado_por bigint,
    revisado_en timestamp with time zone,
    motivo_rechazo text,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizada timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT productos_precio_check CHECK ((precio > (0)::numeric)),
    CONSTRAINT productos_stock_check CHECK ((stock >= 0))
);


ALTER TABLE ecommerce_gt.productos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 36228)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.productos_id_seq OWNER TO postgres;

--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 223
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.productos_id_seq OWNED BY ecommerce_gt.productos.id;


--
-- TOC entry 238 (class 1259 OID 36414)
-- Name: resenas_producto; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.resenas_producto (
    id bigint NOT NULL,
    id_producto bigint NOT NULL,
    id_comprador bigint NOT NULL,
    calificacion smallint NOT NULL,
    comentario text,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT resenas_producto_calificacion_check CHECK (((calificacion >= 1) AND (calificacion <= 5)))
);


ALTER TABLE ecommerce_gt.resenas_producto OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 36413)
-- Name: resenas_producto_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.resenas_producto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.resenas_producto_id_seq OWNER TO postgres;

--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 237
-- Name: resenas_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.resenas_producto_id_seq OWNED BY ecommerce_gt.resenas_producto.id;


--
-- TOC entry 234 (class 1259 OID 36375)
-- Name: tarjetas_pago; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.tarjetas_pago (
    id bigint NOT NULL,
    id_usuario bigint NOT NULL,
    marca character varying(40),
    ultimos4 character(4),
    token character varying(160) NOT NULL,
    mes_exp smallint,
    anio_exp smallint,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tarjetas_pago_anio_exp_check CHECK (((anio_exp >= 2024) AND (anio_exp <= 2100))),
    CONSTRAINT tarjetas_pago_mes_exp_check CHECK (((mes_exp >= 1) AND (mes_exp <= 12)))
);


ALTER TABLE ecommerce_gt.tarjetas_pago OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 36374)
-- Name: tarjetas_pago_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.tarjetas_pago_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.tarjetas_pago_id_seq OWNER TO postgres;

--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 233
-- Name: tarjetas_pago_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.tarjetas_pago_id_seq OWNED BY ecommerce_gt.tarjetas_pago.id;


--
-- TOC entry 220 (class 1259 OID 36198)
-- Name: tokens; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.tokens (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    token text NOT NULL,
    tipo character varying(20) DEFAULT 'JWT'::character varying NOT NULL,
    revocado boolean DEFAULT false NOT NULL,
    expiracion timestamp with time zone,
    creado_en timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ecommerce_gt.tokens OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 36197)
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 219
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.tokens_id_seq OWNED BY ecommerce_gt.tokens.id;


--
-- TOC entry 218 (class 1259 OID 36184)
-- Name: usuarios; Type: TABLE; Schema: ecommerce_gt; Owner: postgres
--

CREATE TABLE ecommerce_gt.usuarios (
    id bigint NOT NULL,
    nombre character varying(120) NOT NULL,
    email ecommerce_gt.citext NOT NULL,
    hash_contrasena text NOT NULL,
    rol ecommerce_gt.rol_usuario DEFAULT 'comun'::ecommerce_gt.rol_usuario NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ecommerce_gt.usuarios OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 36183)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: ecommerce_gt; Owner: postgres
--

CREATE SEQUENCE ecommerce_gt.usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ecommerce_gt.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce_gt; Owner: postgres
--

ALTER SEQUENCE ecommerce_gt.usuarios_id_seq OWNED BY ecommerce_gt.usuarios.id;


--
-- TOC entry 245 (class 1259 OID 36511)
-- Name: vw_productos_en_venta_por_usuario; Type: VIEW; Schema: ecommerce_gt; Owner: postgres
--

CREATE VIEW ecommerce_gt.vw_productos_en_venta_por_usuario AS
 SELECT id_vendedor AS id_usuario,
    count(*) AS productos_en_venta
   FROM ecommerce_gt.productos
  WHERE ((estado = 'aprobado'::ecommerce_gt.estado_producto) AND (stock > 0))
  GROUP BY id_vendedor;


ALTER VIEW ecommerce_gt.vw_productos_en_venta_por_usuario OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 36515)
-- Name: vw_top_clientes_gasto; Type: VIEW; Schema: ecommerce_gt; Owner: postgres
--

CREATE VIEW ecommerce_gt.vw_top_clientes_gasto AS
 SELECT pe.id_comprador AS id_usuario,
    u.nombre,
    u.email,
    sum(pe.monto_total) AS gasto_total,
    count(*) AS pedidos
   FROM (ecommerce_gt.pedidos pe
     JOIN ecommerce_gt.usuarios u ON ((u.id = pe.id_comprador)))
  GROUP BY pe.id_comprador, u.nombre, u.email;


ALTER VIEW ecommerce_gt.vw_top_clientes_gasto OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 36520)
-- Name: vw_top_productos_vendidos; Type: VIEW; Schema: ecommerce_gt; Owner: postgres
--

CREATE VIEW ecommerce_gt.vw_top_productos_vendidos AS
 SELECT ip.id_producto,
    p.nombre,
    sum(ip.cantidad) AS unidades_vendidas,
    sum(ip.total_linea) AS ingresos_brutos,
    sum(ip.ganancia_vendedor) AS ingresos_vendedor,
    sum(ip.comision_plataforma) AS fee_plataforma
   FROM ((ecommerce_gt.items_pedido ip
     JOIN ecommerce_gt.productos p ON ((p.id = ip.id_producto)))
     JOIN ecommerce_gt.pedidos pe ON ((pe.id = ip.id_pedido)))
  WHERE (pe.realizado_en IS NOT NULL)
  GROUP BY ip.id_producto, p.nombre;


ALTER VIEW ecommerce_gt.vw_top_productos_vendidos OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 36525)
-- Name: vw_top_vendedores; Type: VIEW; Schema: ecommerce_gt; Owner: postgres
--

CREATE VIEW ecommerce_gt.vw_top_vendedores AS
 SELECT ip.id_vendedor AS id_usuario,
    u.nombre,
    u.email,
    sum(ip.total_linea) AS ventas_totales,
    sum(ip.cantidad) AS unidades_vendidas,
    count(DISTINCT ip.id_pedido) AS pedidos_participados
   FROM (ecommerce_gt.items_pedido ip
     JOIN ecommerce_gt.usuarios u ON ((u.id = ip.id_vendedor)))
  GROUP BY ip.id_vendedor, u.nombre, u.email;


ALTER VIEW ecommerce_gt.vw_top_vendedores OWNER TO postgres;

--
-- TOC entry 4981 (class 2604 OID 36482)
-- Name: actualizaciones_entrega id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.actualizaciones_entrega ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.actualizaciones_entrega_id_seq'::regclass);


--
-- TOC entry 4955 (class 2604 OID 36265)
-- Name: carritos id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.carritos ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.carritos_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 36223)
-- Name: categorias id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.categorias ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.categorias_id_seq'::regclass);


--
-- TOC entry 4979 (class 2604 OID 36463)
-- Name: historial_estado_pedido id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.historial_estado_pedido ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.historial_estado_pedido_id_seq'::regclass);


--
-- TOC entry 4959 (class 2604 OID 36281)
-- Name: items_carrito id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_carrito ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.items_carrito_id_seq'::regclass);


--
-- TOC entry 4966 (class 2604 OID 36348)
-- Name: items_pedido id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_pedido ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.items_pedido_id_seq'::regclass);


--
-- TOC entry 4977 (class 2604 OID 36446)
-- Name: notificaciones id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.notificaciones ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.notificaciones_id_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 36396)
-- Name: pagos id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pagos ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.pagos_id_seq'::regclass);


--
-- TOC entry 4961 (class 2604 OID 36323)
-- Name: pedidos id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pedidos ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.pedidos_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 36232)
-- Name: productos id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.productos ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.productos_id_seq'::regclass);


--
-- TOC entry 4975 (class 2604 OID 36417)
-- Name: resenas_producto id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.resenas_producto ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.resenas_producto_id_seq'::regclass);


--
-- TOC entry 4970 (class 2604 OID 36378)
-- Name: tarjetas_pago id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tarjetas_pago ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.tarjetas_pago_id_seq'::regclass);


--
-- TOC entry 4946 (class 2604 OID 36201)
-- Name: tokens id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tokens ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.tokens_id_seq'::regclass);


--
-- TOC entry 4942 (class 2604 OID 36187)
-- Name: usuarios id; Type: DEFAULT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.usuarios ALTER COLUMN id SET DEFAULT nextval('ecommerce_gt.usuarios_id_seq'::regclass);


--
-- TOC entry 5256 (class 0 OID 36479)
-- Dependencies: 244
-- Data for Name: actualizaciones_entrega; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5238 (class 0 OID 36262)
-- Dependencies: 226
-- Data for Name: carritos; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.carritos (id, id_usuario, creado_en, fecha_actualizada, estado) VALUES (11, 3, '2025-10-28 01:58:38.669251-06', '2025-10-28 10:00:03.428602-06', 'borrado');
INSERT INTO ecommerce_gt.carritos (id, id_usuario, creado_en, fecha_actualizada, estado) VALUES (12, 3, '2025-10-28 10:22:24.735294-06', '2025-10-28 10:22:36.036981-06', 'borrado');
INSERT INTO ecommerce_gt.carritos (id, id_usuario, creado_en, fecha_actualizada, estado) VALUES (13, 2, '2025-10-28 10:34:15.950462-06', '2025-10-28 10:34:26.238905-06', 'borrado');
INSERT INTO ecommerce_gt.carritos (id, id_usuario, creado_en, fecha_actualizada, estado) VALUES (14, 3, '2025-10-28 13:04:20.756709-06', '2025-10-28 13:05:03.664639-06', 'borrado');


--
-- TOC entry 5234 (class 0 OID 36220)
-- Dependencies: 222
-- Data for Name: categorias; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (1, 'Electrónica');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (2, 'Hogar');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (3, 'Ropa');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (4, 'Deportes');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (5, 'Computación');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (6, 'Juguetes');
INSERT INTO ecommerce_gt.categorias (id, nombre) VALUES (7, 'Libros');


--
-- TOC entry 5254 (class 0 OID 36460)
-- Dependencies: 242
-- Data for Name: historial_estado_pedido; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5240 (class 0 OID 36278)
-- Dependencies: 228
-- Data for Name: items_carrito; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (12, 11, 3, 2, 11.00, '2025-10-28 02:51:04.861845-06');
INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (11, 11, 2, 4, 250.00, '2025-10-28 01:58:38.749787-06');
INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (13, 12, 5, 1, 25.00, '2025-10-28 10:22:24.795328-06');
INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (14, 13, 6, 1, 15.00, '2025-10-28 10:34:15.961459-06');
INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (16, 14, 6, 1, 15.00, '2025-10-28 13:04:23.594131-06');
INSERT INTO ecommerce_gt.items_carrito (id, id_carrito, id_producto, cantidad, precio_unitario, creado_en) VALUES (15, 14, 4, 3, 25.00, '2025-10-28 13:04:20.804973-06');


--
-- TOC entry 5244 (class 0 OID 36345)
-- Dependencies: 232
-- Data for Name: items_pedido; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (5, 10, 2, 3, 4, 250.00);
INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (6, 10, 3, 3, 2, 11.00);
INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (7, 11, 5, 3, 1, 25.00);
INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (8, 12, 6, 3, 1, 15.00);
INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (9, 13, 4, 3, 3, 25.00);
INSERT INTO ecommerce_gt.items_pedido (id, id_pedido, id_producto, id_vendedor, cantidad, precio_unitario) VALUES (10, 13, 6, 3, 1, 15.00);


--
-- TOC entry 5252 (class 0 OID 36443)
-- Dependencies: 240
-- Data for Name: notificaciones; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5248 (class 0 OID 36393)
-- Dependencies: 236
-- Data for Name: pagos; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5242 (class 0 OID 36320)
-- Dependencies: 230
-- Data for Name: pedidos; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.pedidos (id, id_comprador, estado, realizado_en, fecha_prometida_entrega, fecha_entrega, monto_total, direccion_envio) VALUES (12, 2, 'entregado', '2025-10-28 10:34:26.238905-06', '2025-11-03', '2025-10-28', 15.00, 'San Marcos Califronia');
INSERT INTO ecommerce_gt.pedidos (id, id_comprador, estado, realizado_en, fecha_prometida_entrega, fecha_entrega, monto_total, direccion_envio) VALUES (11, 3, 'entregado', '2025-10-28 10:22:36.036981-06', '2025-11-03', '2025-10-28', 25.00, 'Quetzaltengnago');
INSERT INTO ecommerce_gt.pedidos (id, id_comprador, estado, realizado_en, fecha_prometida_entrega, fecha_entrega, monto_total, direccion_envio) VALUES (10, 3, 'entregado', '2025-10-28 10:00:03.428602-06', '2025-11-03', '2025-10-28', 1022.00, 'San Marcos, San Marcos mi casita');
INSERT INTO ecommerce_gt.pedidos (id, id_comprador, estado, realizado_en, fecha_prometida_entrega, fecha_entrega, monto_total, direccion_envio) VALUES (13, 3, 'entregado', '2025-10-28 13:05:03.664639-06', '2025-11-03', '2025-10-28', 90.00, 'Quetzaltenango San MAteo');


--
-- TOC entry 5236 (class 0 OID 36229)
-- Dependencies: 224
-- Data for Name: productos; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.productos (id, id_vendedor, nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria, estado, revisado_por, revisado_en, motivo_rechazo, creado_en, fecha_actualizada) VALUES (2, 3, 'Cafetera Italiana 6 tazas', 'Cafetera de aluminio con difusor de calor.', '/uploads/ba2f2820-1e68-47ee-910d-53004f2ab219.jpg', 250.00, 8, 'nuevo', 2, 'pendiente', NULL, NULL, NULL, '2025-10-26 20:04:32.119868-06', '2025-10-28 10:00:03.428602-06');
INSERT INTO ecommerce_gt.productos (id, id_vendedor, nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria, estado, revisado_por, revisado_en, motivo_rechazo, creado_en, fecha_actualizada) VALUES (3, 3, 'AGUA PURA', 'AGUA PURA SIN NINGUN CONDIMENTO', '/uploads/d4be270e-eef4-432b-ad5c-0e344db2afe5.png', 11.00, 1, 'usado', 2, 'pendiente', NULL, NULL, NULL, '2025-10-27 00:17:47.754732-06', '2025-10-28 10:00:03.428602-06');
INSERT INTO ecommerce_gt.productos (id, id_vendedor, nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria, estado, revisado_por, revisado_en, motivo_rechazo, creado_en, fecha_actualizada) VALUES (5, 3, 'PROTEINA', 'PROTEINA PARA EL GIMNASIO', '/uploads/f6ddcef0-2eae-46df-a87a-11f382693f62.png', 25.00, 19, 'nuevo', 2, 'rechazado', 5, '2025-10-28 13:03:48.917586-06', 'Es que ha sid demasido dificil', '2025-10-27 01:40:35.947998-06', '2025-10-28 13:03:48.917586-06');
INSERT INTO ecommerce_gt.productos (id, id_vendedor, nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria, estado, revisado_por, revisado_en, motivo_rechazo, creado_en, fecha_actualizada) VALUES (4, 3, 'GATORADEE', 'Bebida hidratante que sirve para mejor energía', '/uploads/17f43b03-c825-4ed7-96e6-2d8b35aad26e.png', 25.00, 17, 'usado', 2, 'pendiente', NULL, NULL, NULL, '2025-10-27 00:42:21.912842-06', '2025-10-28 13:05:03.664639-06');
INSERT INTO ecommerce_gt.productos (id, id_vendedor, nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria, estado, revisado_por, revisado_en, motivo_rechazo, creado_en, fecha_actualizada) VALUES (6, 3, 'Taza azul', 'Vendo taza decorativa unicamente decorativa', '/uploads/e9f747ae-9208-4236-8385-e0c5c37eae1a.png', 15.00, 0, 'nuevo', 2, 'pendiente', NULL, NULL, NULL, '2025-10-28 00:40:10.780976-06', '2025-10-28 13:05:03.664639-06');


--
-- TOC entry 5250 (class 0 OID 36414)
-- Dependencies: 238
-- Data for Name: resenas_producto; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5246 (class 0 OID 36375)
-- Dependencies: 234
-- Data for Name: tarjetas_pago; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5232 (class 0 OID 36198)
-- Dependencies: 220
-- Data for Name: tokens; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--



--
-- TOC entry 5230 (class 0 OID 36184)
-- Dependencies: 218
-- Data for Name: usuarios; Type: TABLE DATA; Schema: ecommerce_gt; Owner: postgres
--

INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (1, 'Admin', 'admin@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'admin', true, '2025-10-25 13:30:34.725877-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (2, 'Enmer Sandoval', 'enmer@demo.gt', '$2a$10$HxLFAR80tb.ZKkv0E7HZ8OTR8fi3JtCGMI/VPdlqwZyZP2KopacxW', 'comun', true, '2025-10-26 06:08:19.788679-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (3, 'Shamira Sandoval', 'shamy@demo.gt', '$2a$10$yjCO.HgRqd/3gQNzS2hDdePowA2WKoV8rcw3EsT2MUoAOhDJQb.h6', 'comun', true, '2025-10-26 06:24:34.7237-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (4, 'Juan Sandoval', 'juan@demo.gt', '$2a$10$PZiuvlr2lwJWSid6As7FiOTa0RVzU5t3Y5uyV/1pIIj3vHjn51dDe', 'logistica', true, '2025-10-26 06:25:40.747918-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (5, 'Moderador 1', 'mod1@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'moderador', true, '2025-10-28 11:36:07.005432-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (6, 'Moderador 2', 'mod2@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'moderador', true, '2025-10-28 11:36:07.005432-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (7, 'Moderador 3', 'mod3@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'moderador', true, '2025-10-28 11:36:07.005432-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (8, 'Moderador 4', 'mod4@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'moderador', true, '2025-10-28 11:36:07.005432-06');
INSERT INTO ecommerce_gt.usuarios (id, nombre, email, hash_contrasena, rol, activo, creado_en) VALUES (9, 'Moderador 5', 'mod5@demo.gt', '$2a$10$yez5dFFmcOa5U0qFJiMyGeewr/DcTcSFoEB9XUmX/A.u.G4vtHnj.', 'logistica', true, '2025-10-28 11:36:07.005432-06');


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 243
-- Name: actualizaciones_entrega_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.actualizaciones_entrega_id_seq', 1, false);


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 225
-- Name: carritos_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.carritos_id_seq', 14, true);


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 221
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.categorias_id_seq', 7, true);


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 241
-- Name: historial_estado_pedido_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.historial_estado_pedido_id_seq', 1, false);


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 227
-- Name: items_carrito_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.items_carrito_id_seq', 16, true);


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 231
-- Name: items_pedido_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.items_pedido_id_seq', 10, true);


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 239
-- Name: notificaciones_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.notificaciones_id_seq', 1, false);


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 235
-- Name: pagos_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.pagos_id_seq', 1, false);


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 229
-- Name: pedidos_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.pedidos_id_seq', 13, true);


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 223
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.productos_id_seq', 6, true);


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 237
-- Name: resenas_producto_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.resenas_producto_id_seq', 1, false);


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 233
-- Name: tarjetas_pago_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.tarjetas_pago_id_seq', 1, false);


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 219
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.tokens_id_seq', 1, false);


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: ecommerce_gt; Owner: postgres
--

SELECT pg_catalog.setval('ecommerce_gt.usuarios_id_seq', 9, true);


--
-- TOC entry 5052 (class 2606 OID 36487)
-- Name: actualizaciones_entrega actualizaciones_entrega_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.actualizaciones_entrega
    ADD CONSTRAINT actualizaciones_entrega_pkey PRIMARY KEY (id);


--
-- TOC entry 5016 (class 2606 OID 36270)
-- Name: carritos carritos_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.carritos
    ADD CONSTRAINT carritos_pkey PRIMARY KEY (id);


--
-- TOC entry 5006 (class 2606 OID 36227)
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5008 (class 2606 OID 36225)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- TOC entry 5049 (class 2606 OID 36466)
-- Name: historial_estado_pedido historial_estado_pedido_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.historial_estado_pedido
    ADD CONSTRAINT historial_estado_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 5020 (class 2606 OID 36288)
-- Name: items_carrito items_carrito_id_carrito_id_producto_key; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_carrito
    ADD CONSTRAINT items_carrito_id_carrito_id_producto_key UNIQUE (id_carrito, id_producto);


--
-- TOC entry 5022 (class 2606 OID 36286)
-- Name: items_carrito items_carrito_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_carrito
    ADD CONSTRAINT items_carrito_pkey PRIMARY KEY (id);


--
-- TOC entry 5032 (class 2606 OID 36355)
-- Name: items_pedido items_pedido_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_pedido
    ADD CONSTRAINT items_pedido_pkey PRIMARY KEY (id);


--
-- TOC entry 5047 (class 2606 OID 36451)
-- Name: notificaciones notificaciones_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.notificaciones
    ADD CONSTRAINT notificaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 5040 (class 2606 OID 36401)
-- Name: pagos pagos_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id);


--
-- TOC entry 5027 (class 2606 OID 36330)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 36241)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 5043 (class 2606 OID 36423)
-- Name: resenas_producto resenas_producto_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.resenas_producto
    ADD CONSTRAINT resenas_producto_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 36385)
-- Name: tarjetas_pago tarjetas_pago_id_usuario_token_key; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tarjetas_pago
    ADD CONSTRAINT tarjetas_pago_id_usuario_token_key UNIQUE (id_usuario, token);


--
-- TOC entry 5037 (class 2606 OID 36383)
-- Name: tarjetas_pago tarjetas_pago_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tarjetas_pago
    ADD CONSTRAINT tarjetas_pago_pkey PRIMARY KEY (id);


--
-- TOC entry 5002 (class 2606 OID 36208)
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 36210)
-- Name: tokens tokens_token_key; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tokens
    ADD CONSTRAINT tokens_token_key UNIQUE (token);


--
-- TOC entry 4995 (class 2606 OID 36196)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 4997 (class 2606 OID 36194)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5053 (class 1259 OID 36498)
-- Name: idx_act_entrega_pedido; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_act_entrega_pedido ON ecommerce_gt.actualizaciones_entrega USING btree (id_pedido);


--
-- TOC entry 5050 (class 1259 OID 36477)
-- Name: idx_hist_estado_pedido; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_hist_estado_pedido ON ecommerce_gt.historial_estado_pedido USING btree (id_pedido);


--
-- TOC entry 5017 (class 1259 OID 36299)
-- Name: idx_items_carrito_carrito; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_items_carrito_carrito ON ecommerce_gt.items_carrito USING btree (id_carrito);


--
-- TOC entry 5018 (class 1259 OID 36300)
-- Name: idx_items_carrito_producto; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_items_carrito_producto ON ecommerce_gt.items_carrito USING btree (id_producto);


--
-- TOC entry 5028 (class 1259 OID 36371)
-- Name: idx_items_pedido_pedido; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_items_pedido_pedido ON ecommerce_gt.items_pedido USING btree (id_pedido);


--
-- TOC entry 5029 (class 1259 OID 36372)
-- Name: idx_items_pedido_producto; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_items_pedido_producto ON ecommerce_gt.items_pedido USING btree (id_producto);


--
-- TOC entry 5030 (class 1259 OID 36373)
-- Name: idx_items_pedido_vendedor; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_items_pedido_vendedor ON ecommerce_gt.items_pedido USING btree (id_vendedor);


--
-- TOC entry 5044 (class 1259 OID 36457)
-- Name: idx_notificaciones_tipo; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_notificaciones_tipo ON ecommerce_gt.notificaciones USING btree (tipo);


--
-- TOC entry 5045 (class 1259 OID 36458)
-- Name: idx_notificaciones_usuario; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_notificaciones_usuario ON ecommerce_gt.notificaciones USING btree (id_usuario);


--
-- TOC entry 5038 (class 1259 OID 36412)
-- Name: idx_pagos_pedido; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_pagos_pedido ON ecommerce_gt.pagos USING btree (id_pedido);


--
-- TOC entry 5023 (class 1259 OID 36341)
-- Name: idx_pedidos_comprador; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_pedidos_comprador ON ecommerce_gt.pedidos USING btree (id_comprador);


--
-- TOC entry 5024 (class 1259 OID 36541)
-- Name: idx_pedidos_estado; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_pedidos_estado ON ecommerce_gt.pedidos USING btree (estado);


--
-- TOC entry 5025 (class 1259 OID 36343)
-- Name: idx_pedidos_fecha; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_pedidos_fecha ON ecommerce_gt.pedidos USING btree (realizado_en);


--
-- TOC entry 5009 (class 1259 OID 36257)
-- Name: idx_productos_categoria; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_productos_categoria ON ecommerce_gt.productos USING btree (id_categoria);


--
-- TOC entry 5010 (class 1259 OID 36258)
-- Name: idx_productos_estado; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_productos_estado ON ecommerce_gt.productos USING btree (estado);


--
-- TOC entry 5011 (class 1259 OID 36259)
-- Name: idx_productos_nombre; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_productos_nombre ON ecommerce_gt.productos USING btree (lower((nombre)::text));


--
-- TOC entry 5012 (class 1259 OID 36260)
-- Name: idx_productos_vendedor; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_productos_vendedor ON ecommerce_gt.productos USING btree (id_vendedor);


--
-- TOC entry 5041 (class 1259 OID 36441)
-- Name: idx_resenas_producto_prod; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_resenas_producto_prod ON ecommerce_gt.resenas_producto USING btree (id_producto);


--
-- TOC entry 5033 (class 1259 OID 36391)
-- Name: idx_tarjetas_pago_usuario; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_tarjetas_pago_usuario ON ecommerce_gt.tarjetas_pago USING btree (id_usuario);


--
-- TOC entry 4998 (class 1259 OID 36218)
-- Name: idx_tokens_expiracion; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_tokens_expiracion ON ecommerce_gt.tokens USING btree (expiracion);


--
-- TOC entry 4999 (class 1259 OID 36217)
-- Name: idx_tokens_revocado; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_tokens_revocado ON ecommerce_gt.tokens USING btree (revocado);


--
-- TOC entry 5000 (class 1259 OID 36216)
-- Name: idx_tokens_usuario; Type: INDEX; Schema: ecommerce_gt; Owner: postgres
--

CREATE INDEX idx_tokens_usuario ON ecommerce_gt.tokens USING btree (usuario_id);


--
-- TOC entry 5077 (class 2620 OID 36533)
-- Name: carritos trg_carritos_actualizada; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_carritos_actualizada BEFORE UPDATE ON ecommerce_gt.carritos FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.set_fecha_actualizada();


--
-- TOC entry 5078 (class 2620 OID 36536)
-- Name: items_pedido trg_items_pedido_total_del; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_items_pedido_total_del AFTER DELETE ON ecommerce_gt.items_pedido FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.trigger_refrescar_total_pedido();


--
-- TOC entry 5079 (class 2620 OID 36534)
-- Name: items_pedido trg_items_pedido_total_ins; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_items_pedido_total_ins AFTER INSERT ON ecommerce_gt.items_pedido FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.trigger_refrescar_total_pedido();


--
-- TOC entry 5080 (class 2620 OID 36535)
-- Name: items_pedido trg_items_pedido_total_upd; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_items_pedido_total_upd AFTER UPDATE ON ecommerce_gt.items_pedido FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.trigger_refrescar_total_pedido();


--
-- TOC entry 5075 (class 2620 OID 36532)
-- Name: productos trg_producto_vuelve_pendiente; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_producto_vuelve_pendiente BEFORE UPDATE OF nombre, descripcion, imagen_url, precio, stock, condicion, id_categoria ON ecommerce_gt.productos FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.producto_vuelve_pendiente();


--
-- TOC entry 5076 (class 2620 OID 36531)
-- Name: productos trg_productos_actualizada; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_productos_actualizada BEFORE UPDATE ON ecommerce_gt.productos FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.set_fecha_actualizada();


--
-- TOC entry 5081 (class 2620 OID 36537)
-- Name: resenas_producto trg_validar_resena; Type: TRIGGER; Schema: ecommerce_gt; Owner: postgres
--

CREATE TRIGGER trg_validar_resena BEFORE INSERT ON ecommerce_gt.resenas_producto FOR EACH ROW EXECUTE FUNCTION ecommerce_gt.validar_elegibilidad_resena();


--
-- TOC entry 5073 (class 2606 OID 36488)
-- Name: actualizaciones_entrega actualizaciones_entrega_id_pedido_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.actualizaciones_entrega
    ADD CONSTRAINT actualizaciones_entrega_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES ecommerce_gt.pedidos(id) ON DELETE CASCADE;


--
-- TOC entry 5074 (class 2606 OID 36493)
-- Name: actualizaciones_entrega actualizaciones_entrega_id_usuario_logistica_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.actualizaciones_entrega
    ADD CONSTRAINT actualizaciones_entrega_id_usuario_logistica_fkey FOREIGN KEY (id_usuario_logistica) REFERENCES ecommerce_gt.usuarios(id);


--
-- TOC entry 5058 (class 2606 OID 36271)
-- Name: carritos carritos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.carritos
    ADD CONSTRAINT carritos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES ecommerce_gt.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5071 (class 2606 OID 36472)
-- Name: historial_estado_pedido historial_estado_pedido_cambiado_por_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.historial_estado_pedido
    ADD CONSTRAINT historial_estado_pedido_cambiado_por_fkey FOREIGN KEY (cambiado_por) REFERENCES ecommerce_gt.usuarios(id);


--
-- TOC entry 5072 (class 2606 OID 36467)
-- Name: historial_estado_pedido historial_estado_pedido_id_pedido_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.historial_estado_pedido
    ADD CONSTRAINT historial_estado_pedido_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES ecommerce_gt.pedidos(id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 36289)
-- Name: items_carrito items_carrito_id_carrito_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_carrito
    ADD CONSTRAINT items_carrito_id_carrito_fkey FOREIGN KEY (id_carrito) REFERENCES ecommerce_gt.carritos(id) ON DELETE CASCADE;


--
-- TOC entry 5060 (class 2606 OID 36294)
-- Name: items_carrito items_carrito_id_producto_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_carrito
    ADD CONSTRAINT items_carrito_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES ecommerce_gt.productos(id);


--
-- TOC entry 5062 (class 2606 OID 36356)
-- Name: items_pedido items_pedido_id_pedido_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_pedido
    ADD CONSTRAINT items_pedido_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES ecommerce_gt.pedidos(id) ON DELETE CASCADE;


--
-- TOC entry 5063 (class 2606 OID 36361)
-- Name: items_pedido items_pedido_id_producto_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_pedido
    ADD CONSTRAINT items_pedido_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES ecommerce_gt.productos(id);


--
-- TOC entry 5064 (class 2606 OID 36366)
-- Name: items_pedido items_pedido_id_vendedor_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.items_pedido
    ADD CONSTRAINT items_pedido_id_vendedor_fkey FOREIGN KEY (id_vendedor) REFERENCES ecommerce_gt.usuarios(id);


--
-- TOC entry 5070 (class 2606 OID 36452)
-- Name: notificaciones notificaciones_id_usuario_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.notificaciones
    ADD CONSTRAINT notificaciones_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES ecommerce_gt.usuarios(id) ON DELETE SET NULL;


--
-- TOC entry 5066 (class 2606 OID 36402)
-- Name: pagos pagos_id_pedido_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pagos
    ADD CONSTRAINT pagos_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES ecommerce_gt.pedidos(id) ON DELETE CASCADE;


--
-- TOC entry 5067 (class 2606 OID 36407)
-- Name: pagos pagos_id_tarjeta_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pagos
    ADD CONSTRAINT pagos_id_tarjeta_fkey FOREIGN KEY (id_tarjeta) REFERENCES ecommerce_gt.tarjetas_pago(id);


--
-- TOC entry 5061 (class 2606 OID 36331)
-- Name: pedidos pedidos_id_comprador_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.pedidos
    ADD CONSTRAINT pedidos_id_comprador_fkey FOREIGN KEY (id_comprador) REFERENCES ecommerce_gt.usuarios(id);


--
-- TOC entry 5055 (class 2606 OID 36247)
-- Name: productos productos_id_categoria_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.productos
    ADD CONSTRAINT productos_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES ecommerce_gt.categorias(id);


--
-- TOC entry 5056 (class 2606 OID 36242)
-- Name: productos productos_id_vendedor_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.productos
    ADD CONSTRAINT productos_id_vendedor_fkey FOREIGN KEY (id_vendedor) REFERENCES ecommerce_gt.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5057 (class 2606 OID 36252)
-- Name: productos productos_revisado_por_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.productos
    ADD CONSTRAINT productos_revisado_por_fkey FOREIGN KEY (revisado_por) REFERENCES ecommerce_gt.usuarios(id);


--
-- TOC entry 5068 (class 2606 OID 36431)
-- Name: resenas_producto resenas_producto_id_comprador_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.resenas_producto
    ADD CONSTRAINT resenas_producto_id_comprador_fkey FOREIGN KEY (id_comprador) REFERENCES ecommerce_gt.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5069 (class 2606 OID 36426)
-- Name: resenas_producto resenas_producto_id_producto_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.resenas_producto
    ADD CONSTRAINT resenas_producto_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES ecommerce_gt.productos(id) ON DELETE CASCADE;


--
-- TOC entry 5065 (class 2606 OID 36386)
-- Name: tarjetas_pago tarjetas_pago_id_usuario_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tarjetas_pago
    ADD CONSTRAINT tarjetas_pago_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES ecommerce_gt.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 36211)
-- Name: tokens tokens_usuario_id_fkey; Type: FK CONSTRAINT; Schema: ecommerce_gt; Owner: postgres
--

ALTER TABLE ONLY ecommerce_gt.tokens
    ADD CONSTRAINT tokens_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES ecommerce_gt.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA ecommerce_gt; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA ecommerce_gt TO dev;


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE actualizaciones_entrega; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.actualizaciones_entrega TO dev;


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 243
-- Name: SEQUENCE actualizaciones_entrega_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.actualizaciones_entrega_id_seq TO dev;


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE carritos; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.carritos TO dev;


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE carritos_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.carritos_id_seq TO dev;


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE categorias; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.categorias TO dev;


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE categorias_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.categorias_id_seq TO dev;


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE historial_estado_pedido; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.historial_estado_pedido TO dev;


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 241
-- Name: SEQUENCE historial_estado_pedido_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.historial_estado_pedido_id_seq TO dev;


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE items_carrito; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.items_carrito TO dev;


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE items_carrito_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.items_carrito_id_seq TO dev;


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE items_pedido; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.items_pedido TO dev;


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE items_pedido_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.items_pedido_id_seq TO dev;


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE notificaciones; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.notificaciones TO dev;


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 239
-- Name: SEQUENCE notificaciones_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.notificaciones_id_seq TO dev;


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE pagos; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.pagos TO dev;


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 235
-- Name: SEQUENCE pagos_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.pagos_id_seq TO dev;


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE pedidos; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.pedidos TO dev;


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE pedidos_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.pedidos_id_seq TO dev;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE productos; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.productos TO dev;


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE productos_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.productos_id_seq TO dev;


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE resenas_producto; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.resenas_producto TO dev;


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 237
-- Name: SEQUENCE resenas_producto_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.resenas_producto_id_seq TO dev;


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE tarjetas_pago; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.tarjetas_pago TO dev;


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE tarjetas_pago_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.tarjetas_pago_id_seq TO dev;


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE tokens; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.tokens TO dev;


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE tokens_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.tokens_id_seq TO dev;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE usuarios; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.usuarios TO dev;


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE usuarios_id_seq; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE ecommerce_gt.usuarios_id_seq TO dev;


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE vw_productos_en_venta_por_usuario; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.vw_productos_en_venta_por_usuario TO dev;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE vw_top_clientes_gasto; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.vw_top_clientes_gasto TO dev;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE vw_top_productos_vendidos; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.vw_top_productos_vendidos TO dev;


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE vw_top_vendedores; Type: ACL; Schema: ecommerce_gt; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ecommerce_gt.vw_top_vendedores TO dev;


--
-- TOC entry 2236 (class 826 OID 36539)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: ecommerce_gt; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ecommerce_gt GRANT SELECT,USAGE ON SEQUENCES TO dev;


--
-- TOC entry 2235 (class 826 OID 36538)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: ecommerce_gt; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ecommerce_gt GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO dev;


-- Completed on 2025-10-28 14:14:57

--
-- PostgreSQL database dump complete
--

