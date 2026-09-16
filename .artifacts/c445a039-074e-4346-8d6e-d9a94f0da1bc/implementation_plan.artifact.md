# Plan: Sincronización de Base de Datos y Refresco de Interfaz

Este plan aborda el error de duplicidad de ID (requiere acción del usuario en Supabase) y optimiza el sistema de refresco de datos para asegurar que las actualizaciones de productos sean visibles de inmediato.

## User Action Required

> [!CAUTION]
> **IMPORTANTE: Sincronizar Contador de ID**
> Para solucionar el error `duplicate key`, debes ejecutar este comando en el **SQL Editor** de tu panel de Supabase:
> ```sql
> SELECT setval('producto_id_seq', (SELECT MAX(id) FROM producto));
> ```
> Esto arreglará el contador de la tabla `producto` que está causando el conflicto.

## Proposed Changes

### [Servicios]

#### [MODIFY] [producto_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/producto_service.dart)
- Modificar `actualizarProducto` para usar el método `.select().single()` al final. Esto obliga a Supabase a devolver el registro actualizado y confirma que la operación se realizó con éxito sobre el ID correcto.

---

### [Providers]

#### [MODIFY] [producto_admin_provider.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/providers/producto_admin_provider.dart)
- Asegurar que `cargarProductos` limpie la lista anterior antes de recibir la nueva, forzando un redibujado total de la interfaz.

---

### [Screens]

#### [MODIFY] [detalle_producto_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/detalle_producto_screen.dart)
- Incrementar el padding inferior del `bottomSheet` a **120px** para elevar los botones a una posición óptima.

#### [MODIFY] [actualizar_producto_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/admin/actualizar_producto_screen.dart)
- Añadir un indicador de éxito (SnackBar verde) más persistente para confirmar visualmente al administrador que el cambio se guardó en la nube.

## Verification Plan

### Manual Verification
1. **Creación**: Tras ejecutar el SQL en Supabase, intentar crear un producto. El ID debe asignarse automáticamente.
2. **Actualización**: Cambiar un precio, guardar y verificar que la lista principal cambie al instante sin necesidad de salir y volver a entrar.
3. **Interfaz**: Confirmar que el botón "AGREGAR" en el detalle está a una altura cómoda.
