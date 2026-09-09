# Plan: Ajuste de Restricción de Tipo en PQRS

Basado en la restricción `CHECK` exacta para la columna `tipo` (`'pregunta'`, `'queja'`, `'reclamo'`, `'sugerencia'`, `'felicitacion'`), este plan normaliza los tipos de PQRS para cumplir estrictamente con los valores permitidos en la base de datos.

## User Review Required

> [!IMPORTANT]
> - **Cambio de "Petición" a "Pregunta"**: Tu base de datos usa el término `'pregunta'`. Actualizaré la aplicación para que internamente envíe `'pregunta'` cuando el usuario elija "Petición" (o cambiaré el nombre visual si prefieres).
> - **Minúsculas y Tildes**: Se eliminarán las tildes y se usarán minúsculas para los valores de envío (`'queja'`, `'reclamo'`, etc.), pero mantendremos los nombres bonitos en la pantalla.

## Proposed Changes

### [Screens]

#### [MODIFY] [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/pqrs_screen.dart)
- Actualizar el enum `TipoPqrs` para incluir `felicitacion`.
- Modificar `TipoPqrsX.etiqueta` para que devuelva los valores exactos del ARRAY de Supabase:
    - `peticion` -> `'pregunta'`
    - `queja` -> `'queja'`
    - `reclamo` -> `'reclamo'`
    - `sugerencia` -> `'sugerencia'`
    - `felicitacion` -> `'felicitacion'`
- Crear una propiedad `etiquetaVisual` para mostrar "Petición", "Queja", etc., en la interfaz.

## Verification Plan

### Manual Verification
1. **Envío de PQRS**: Probar el envío de cada tipo. Al enviar `'pregunta'` o `'queja'` en minúsculas y sin tildes, Supabase ya no debe arrojar el error `pqrs_tipo_check`.
