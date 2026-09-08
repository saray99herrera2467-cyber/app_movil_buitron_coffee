# Plan: Align PQRS Module with Supabase Schema

The user has provided the exact schema for the `pqrs` table in Supabase. The current implementation uses different column names (e.g., `correo` instead of `email`, `radicado` instead of `codigo_referencia`) and is missing the `id_usuario` field during insertion.

## User Review Required

> [!IMPORTANT]
> The provided schema does not include an `asunto` (Subject) column. I will merge the content of the "Asunto" field into the "Descripción" field when saving to ensure no user input is lost.
> I will use the exact column names provided, including potential typos like `frecha_creacion` and `codigo_referencia`, to ensure compatibility with the existing database.

## Proposed Changes

### [Screens]

#### [MODIFY] [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/pqrs_screen.dart)
- Update `_enviar` method:
    - Fetch `id_usuario` using `AuthService.obtenerIdSesion()`.
    - Map fields to the new schema:
        - `correo` -> `email`
        - `radicado` -> `codigo_referencia`
        - `fecha` -> `frecha_creacion`
        - Prepend `asunto` to `descripcion`.
    - Ensure `fecha_actualizacion` is also set if required, or let Supabase handle it.

#### [MODIFY] [pqrs_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/admin/pqrs_screen.dart)
- Update `_cargarPqrs` and UI mapping:
    - Replace `radicado` with `codigo_referencia`.
    - Replace `correo` with `email`.
    - Replace `fecha` with `frecha_creacion`.
- Update `_actualizarEstado` to use the `codigo_referencia` column for filtering.
- Update `mostrarDetalle` dialog to show and allow updating the `respuesta` (Response) field, which is part of the new schema.

### [Services]

#### [MODIFY] [pqrs_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/pqrs_service.dart)
- Update `obtenerTodas` to order by `frecha_creacion`.
- Update `actualizarEstado` to use `codigo_referencia`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` on both `pqrs_screen.dart` files to ensure no regressions.

### Manual Verification
- Verify that sending a PQRS as a user now correctly populates the `id_usuario` and uses the `email` and `codigo_referencia` columns.
- Verify that the Admin can see these records and that the "Response" field is accessible.
