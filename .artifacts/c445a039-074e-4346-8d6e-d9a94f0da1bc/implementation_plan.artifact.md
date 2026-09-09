# Plan: Solución Definitiva PQRS, Recuperación de Clave y Seguimiento Visual

Este plan aborda el error persistente de PQRS usando el valor exacto de la base de datos, completa el flujo de restablecimiento de contraseña y añade una línea de tiempo para el seguimiento de productos.

## User Review Required

> [!IMPORTANT]
> - **PQRS**: Usaré el valor exacto `'Pendiente'` (P mayúscula). Si el error `pqrs_estado_check` persiste, es posible que la restricción en Supabase tenga un espacio extra o use un valor diferente.
> - **Seguimiento**: Implementaré un widget de línea de tiempo en el detalle del pedido para visualizar los estados: Pendiente -> Pagado -> Enviado -> Entregado.
> - **Clave**: Se creará la pantalla `RestablecerClaveScreen`. Para que funcione, el usuario debe abrir el enlace que llega a su correo; Supabase abrirá la app y allí podrá cambiar la contraseña.

## Proposed Changes

### [Services]

#### [MODIFY] [auth_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/auth_service.dart)
- Añadir método `actualizarClave(String nuevaClave)` para finalizar el proceso de recuperación.

### [Screens]

#### [MODIFY] [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/pqrs_screen.dart)
- Enviar explícitamente `'estado': 'Pendiente'`.

#### [NEW] [restablecer_clave_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/restablecer_clave_screen.dart)
- Crear pantalla con validación de contraseña para el cambio final.

#### [MODIFY] [historial_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/historial_screen.dart)
- Añadir el widget `_LineaTiempoPedido` en el modal de detalle del pedido para mostrar el progreso del envío.

## Verification Plan

### Manual Verification
1. **PQRS**: Intentar enviar y verificar que no hay error 23514.
2. **Seguimiento**: Ver un pedido en el historial y confirmar que la línea de tiempo se marca según el estado.
3. **Clave**: Probar el envío de correo y la navegación a la nueva pantalla.
