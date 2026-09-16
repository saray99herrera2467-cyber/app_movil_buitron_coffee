# Plan: Corrección de Actualización de Productos y Mejora de Mensajes

Este plan aborda el error persistente en la actualización de productos (donde el sistema no encuentra el ID) y mejora la legibilidad de los avisos (SnackBars) al agregar productos al carrito.

## User Review Required

> [!IMPORTANT]
> - **Error de ID en Actualización**: El error `PGRST116` indica que no se encuentran filas para actualizar. He detectado que esto puede ocurrir por restricciones de seguridad (RLS) o por una discrepancia en el tipo de dato del ID.
> - **Legibilidad de Avisos**: Se cambiará el diseño de los letreros de confirmación a un fondo oscuro con letras blancas y botones naranja brillante para garantizar que sean fáciles de leer.

## Proposed Changes

### [Servicios]

#### [MODIFY] [producto_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/producto_service.dart)
- Rediseñar `actualizarProducto` para:
    1. Asegurar que el ID se envíe como un entero puro.
    2. Eliminar la verificación estricta de `.select().single()` que causa el error `PGRST116`.
    3. Usar un bloque `try-catch` más detallado para reportar si el problema es de conexión, de permisos (RLS) o de datos no encontrados.

---

### [Screens - Catálogo]

#### [MODIFY] [catalogo_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/catalogo_screen.dart)
- Actualizar `_agregarAlCarrito`:
    - Cambiar el fondo del SnackBar a un gris muy oscuro o negro (`Color(0xFF1A1A1A)`).
    - Asegurar que el texto sea blanco puro y el botón "VER" use el naranja de la marca para máximo contraste.

## Verification Plan

### Manual Verification
1. **Actualización**: Editar el nombre de un producto existente. El sistema debe confirmar el guardado sin errores. Si falla, el nuevo log nos dirá exactamente por qué.
2. **SnackBar**: Agregar un producto al carrito y verificar que el letrero inferior sea perfectamente legible y el botón "VER" destaque claramente.
