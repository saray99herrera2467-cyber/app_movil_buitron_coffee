# Plan: Solución Definitiva de Creación de Productos y Ajuste Visual de Detalle

Este plan aborda el error de duplicidad de ID en la creación de productos mediante un saneamiento estricto de datos y optimiza la visibilidad de los botones en la pantalla de detalle del producto.

## User Review Required

> [!IMPORTANT]
> - **Sincronización de Base de Datos**: Si tras aplicar este cambio el error persiste, será necesario ejecutar una instrucción SQL en tu consola de Supabase para sincronizar el contador de IDs (Sequence), ya que la base de datos podría estar intentando asignar un número que ya existe.
> - **Ajuste de Interfaz**: Se elevarán significativamente los botones en la pantalla de detalle para asegurar que no interfieran con la barra de navegación del celular.

## Proposed Changes

### [Servicios]

#### [MODIFY] [producto_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/producto_service.dart)
- Reforzar `crearProducto` para enviar únicamente las columnas de datos necesarias, garantizando que el campo `id` nunca se envíe a Supabase. Esto forzará a la base de datos a usar su generador automático de IDs.

---

### [Screens]

#### [MODIFY] [detalle_producto_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/detalle_producto_screen.dart)
- Incrementar el padding inferior del contenedor de botones a **85px** (antes 45px) para que aparezcan mucho más arriba y sean fáciles de tocar.

## Verification Plan

### Manual Verification
1. **Admin**: Crear un producto nuevo. Si falla, el error confirmará si la "Sequence" de Postgres está desincronizada.
2. **Usuario**: Abrir un producto y verificar que el botón "AGREGAR AL CARRITO" esté posicionado cómodamente arriba.
