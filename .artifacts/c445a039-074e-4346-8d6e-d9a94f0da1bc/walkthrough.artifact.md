# Walkthrough: Solución Definitiva de Restricciones en PQRS

He ajustado el módulo de PQRS para cumplir estrictamente con las reglas de validación (`CHECK constraints`) de tu base de datos en Supabase, tanto para la columna `estado` como para la columna `tipo`.

## Cambios Realizados

### [Mapeo de Datos - Pantalla de Usuario]

#### [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/pqrs_screen.dart)
- **Normalización de Tipos**: Siguiendo la regla `CHECK` de Supabase, he mapeado los tipos a sus valores exactos en minúsculas y sin tildes:
    - Petición ➔ **`'pregunta'`**
    - Queja ➔ **`'queja'`**
    - Reclamo ➔ **`'reclamo'`**
    - Sugerencia ➔ **`'sugerencia'`**
    - Felicitación ➔ **`'felicitacion'`**
- **Estado Pascal**: Se mantuvo el envío del estado como **`'pendiente'`** en minúsculas, cumpliendo con la otra restricción detectada.
- **Interfaz Amigable**: En la pantalla seguirás viendo los nombres con tildes y mayúsculas, pero la app se encarga de "traducirlos" al formato técnico antes de enviarlos.

### [Gestión Administrativa]

#### [admin/pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/admin/pqrs_screen.dart)
- **Sincronización de Estados**: Se actualizaron los selectores para manejar `'pendiente'`, `'en proceso'`, `'resuelta'` y `'cerrada'`.
- **Visibilidad Detallada**: Ahora se muestra el tipo de solicitud en el detalle del administrador de forma clara.

## Resultados de Verificación

- Se ejecutó `flutter analyze` y el código está **limpio de errores**.
- Los valores de envío coinciden letra por letra con los ARRAYs definidos en tus restricciones SQL.

> [!TIP]
> **Prueba final**: Intenta enviar una "Petición". La base de datos recibirá `'pregunta'` y el estado `'pendiente'`, lo cual debería ser aceptado sin problemas por Supabase.
