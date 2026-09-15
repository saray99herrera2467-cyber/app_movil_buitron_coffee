# Plan: Implementación de Subida de Imágenes Reales (Supabase Storage)

Este plan permite que el administrador seleccione fotos directamente desde su galería o cámara y las suba a la nube de Supabase, vinculándolas automáticamente a los productos.

## User Review Required

> [!IMPORTANT]
> - **Bucket en Supabase**: Para que esto funcione, debes entrar a tu panel de Supabase -> **Storage** y crear un **Bucket** llamado `productos`. Asegúrate de ponerlo como **Público**.
> - **Dependencia**: Se agregará la librería `image_picker` para permitir el acceso a la cámara y galería.

## Proposed Changes

### [Configuración]

#### [MODIFY] [pubspec.yaml](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/pubspec.yaml)
- Añadir la dependencia `image_picker: ^1.1.2`.

#### [MODIFY] [api_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/api_service.dart)
- Añadir la constante `static const String bucketProductos = 'productos';`.

---

### [Servicios]

#### [NEW] [storage_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/storage_service.dart)
- Implementar métodos para:
    - Seleccionar imagen desde galería/cámara.
    - Subir archivo al bucket `productos`.
    - Obtener la URL pública del archivo subido.

---

### [Pantallas de Administrador]

#### [MODIFY] [crear_producto_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/admin/crear_producto_screen.dart)
- Añadir un botón visual para "Seleccionar Imagen".
- Mostrar una vista previa de la foto elegida.
- Modificar el guardado para que primero suba la imagen a Storage y luego guarde el producto con esa URL.

#### [MODIFY] [actualizar_producto_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/admin/actualizar_producto_screen.dart)
- Implementar la misma lógica para permitir cambiar la imagen de un producto existente.

## Verification Plan

### Manual Verification
1. **Selección**: Abrir la pantalla de Crear Producto, tocar el botón de imagen y elegir una foto de la galería.
2. **Subida**: Guardar el producto y verificar en el panel de Supabase -> Storage -> productos que la imagen esté ahí.
3. **Visualización**: Confirmar que el nuevo producto aparece en el catálogo con la foto real.
