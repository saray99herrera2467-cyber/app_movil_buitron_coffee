# Plan de Implementación: Optimización de Gestión de Pedidos y Seguimiento

El usuario desea mejorar la experiencia del administrador al guardar el seguimiento de un pedido. Actualmente, la operación no muestra un indicador de carga (lo que genera incertidumbre sobre si se guardó o no) y no cambia automáticamente el estado del pedido a "EN CAMINO".

## Cambios Propuestos

### 1. Capa de Datos/Servicio (`lib/services/pedido_service.dart`)
*   Modificar el método `actualizarSeguimiento` para que, además de registrar el número de guía y la transportadora, actualice la columna `estado` a `'EN CAMINO'`. De esta manera se realiza en una sola transacción eficiente con Supabase.

### 2. Capa de Interfaz de Usuario (`lib/screens/admin/gestion_pedidos_screen.dart`)
*   **Indicador de Carga**: En el botón "GUARDAR SEGUIMIENTO", envolver la llamada asíncrona mostrando un `showDialog` con un `CircularProgressIndicator` para dar retroalimentación visual inmediata.
*   **Cierre de Diálogos**: Al finalizar con éxito, cerrar el diálogo de carga y el panel inferior (`bottom sheet`), y recargar la lista de pedidos de forma automática.
*   **Soporte Completo del Estado "EN CAMINO"**:
    *   Agregar el estado `en camino` al listado de filtros superiores (`_chipFiltro`).
    *   Asignar un color distintivo (por ejemplo, `Colors.blue`) al estado en la función `_colorEstado`.
    *   Incluir la opción "En Camino" dentro de los elementos válidos del `DropdownButtonFormField` de cada tarjeta de pedido para evitar errores de renderizado de Flutter cuando un pedido cambie a este estado.

## Plan de Verificación

### Pruebas Automatizadas
*   Ejecutar `flutter analyze` para asegurar que las modificaciones en los enums/estados y componentes visuales no rompan la tipación.

### Verificación Manual
*   Ingresar al panel de administración -> Gestión de Pedidos.
*   Abrir el detalle de un pedido pendiente, ingresar número de guía, transportadora y presionar "GUARDAR SEGUIMIENTO".
*   Verificar que aparezca el círculo de progreso de carga.
*   Verificar que al completarse, se cierre el detalle y el pedido pase automáticamente al estado "EN CAMINO" con su color correspondiente y filtro funcional.
