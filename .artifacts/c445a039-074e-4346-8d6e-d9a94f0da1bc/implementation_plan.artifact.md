# Plan: Sincronización Total con el Esquema de Supabase (Diagrama)

Este plan asegura que el 100% del código de Flutter coincida con las tablas y columnas mostradas en las imágenes de tu base de datos, garantizando que no haya fallos al guardar pedidos, usuarios o productos.

## User Review Required

> [!IMPORTANT]
> - **Nombres con Ñ**: Se respetará el nombre de la tabla `reseñas`.
> - **Nuevos Campos en Pedidos**: Se integrarán las columnas `referencia_pago` y `envio`.
> - **Integridad de Usuario**: Se verificará que el campo `nombre_usuario` sea el que se use en todas las consultas.

## Proposed Changes

### [Servicios Base]

#### [MODIFY] [api_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/api_service.dart)
- Definir todas las tablas del diagrama:
    - `tablaRoles = 'rol'`
    - `tablaUsuarios = 'usuario'`
    - `tablaProductos = 'producto'`
    - `tablaCarrito = 'carrito'`
    - `tablaPedidos = 'pedido'`
    - `tablaDetallePedido = 'detalle_pedido'`
    - `tablaResenas = 'reseñas'`
    - `tablaPqrs = 'pqrs'`
    - `tablaVerificacionesEmail = 'verificaciones_email'`
    - `tablaNotificacionesAdmin = 'notificaciones_admin'`
    - `tablaPromociones = 'promociones'`

### [Lógica de Pedidos]

#### [MODIFY] [pedido_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/pedido_service.dart)
- Actualizar `crearPedido` para incluir `referencia_pago`, `envio` y asegurar el uso de `direccion`.

### [Modelos de Datos]

#### [MODIFY] [producto.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/models/producto.dart)
- Asegurar que `calificacion_promedio` sea `double` y `total_resenas` sea `int`.

#### [MODIFY] [resena.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/models/resena.dart)
- Sincronizar campos: `producto_id`, `usuario_id`, `nombre_usuario`, `calificacion`, `comentario`, `fecha`, `estado`.

## Verification Plan

### Automated Tests
- Ejecutar `flutter analyze` para confirmar consistencia.

### Manual Verification
1. **Flujo de Compra**: Realizar un pedido y verificar en el panel de Supabase que los campos `envio` y `referencia_pago` se llenen correctamente.
2. **Administrador**: Abrir la lista de usuarios y confirmar que se carguen desde la tabla `usuario` sin errores de columna.
