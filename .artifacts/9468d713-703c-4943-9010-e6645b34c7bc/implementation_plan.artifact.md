# Plan de Ajustes Finales: Perfil, Reseñas, PQRS y Carrito

Este plan aborda los problemas de persistencia en el perfil, la selección de productos en reseñas, el envío de solicitudes y la mejora de la experiencia de usuario en el carrito y el menú lateral.

## Revisión del Usuario Requerida

> [!IMPORTANT]
> **Consistencia de Nombres:** He notado que en algunas partes se usa `id_producto` y en otras `producto_id`. Estandarizaré esto basándome en lo que parece ser el esquema de tu base de datos para que las reseñas y PQRS se guarden correctamente.

## Cambios Propuestos

### 1. Carrito de Compras (Gestión de Productos)
#### [MODIFY] [carrito_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/carrito_screen.dart)
- Añadir un botón de eliminar (icono de basura) al lado de cada producto para quitarlo completamente del carrito sin tener que bajar la cantidad a cero manualmente.

### 2. Perfil de Usuario (Solución de Guardado)
#### [MODIFY] [perfil_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/perfil_screen.dart)
- Mejorar el feedback visual al guardar.
- Asegurar que los controladores de texto se actualicen correctamente tras la respuesta de la base de datos.
- Añadir un mensaje de error más detallado si el guardado falla para identificar si es un problema de columnas.

### 3. Reseñas y PQRS (Envío Real)
#### [MODIFY] [resenas_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/resenas_screen.dart)
- Asegurar que el selector de productos sea obligatorio y no tenga nada preseleccionado al entrar.
- Corregir los nombres de los campos enviados a Supabase (ej: asegurar si es `producto_id` o `id_producto`).
- Añadir estado de carga en el botón de envío.

#### [MODIFY] [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/pqrs_screen.dart)
- Verificar que la tabla `pqrs` reciba los datos correctamente.

### 4. Estética (Menú Lateral)
#### [MODIFY] [catalogo_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/catalogo_screen.dart)
- Ajustar el tamaño y posición del logo `assets/login.png` en el Drawer para que coincida con el estilo de la marca.

## Plan de Verificación

### Verificación Manual
1. **Carrito:** Añadir 2 productos y eliminar uno con el nuevo botón de basura.
2. **Reseñas:** Seleccionar un café de la lista, calificarlo, enviarlo y ver el mensaje de "Esperando aprobación".
3. **Perfil:** Cambiar el nombre, guardar y recargar la pantalla para confirmar que persiste.
