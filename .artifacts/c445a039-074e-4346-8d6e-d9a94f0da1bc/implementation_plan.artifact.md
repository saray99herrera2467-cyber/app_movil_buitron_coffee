# Plan: Registration Restrictions and Order Deletion

I will implement the requested restrictions for the registration process and add the ability to delete orders from the purchase history.

## User Review Required

> [!IMPORTANT]
> - I will add a new "Número de documento" field to the registration screen since it was missing from the UI but present in the service.
> - Deleting an order will also remove its associated details in `detalle_pedido` to ensure database integrity.

## Proposed Changes

### [Screens]

#### [MODIFY] [registro_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/registro_screen.dart)
- Add `documentoController`.
- Add a new text field for "Número de documento" with:
    - `maxLength: 11`
    - Numeric keyboard.
- Update the "Teléfono" text field with:
    - `maxLength: 10`
    - Numeric keyboard.
- Update `registrarse()` logic to validate these lengths and pass the document to the service.

#### [MODIFY] [historial_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/historial_screen.dart)
- Add a trash icon button to each order card.
- Implement a confirmation dialog: "¿Estás seguro de que deseas eliminar este pedido?".
- Call the deletion service and refresh the list upon success.

### [Services]

#### [MODIFY] [historial_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/historial_service.dart)
- Add `eliminarPedido(int idPedido)`:
    - Delete entries from `detalle_pedido` first (to handle foreign key constraints).
    - Delete the entry from `pedido`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` on the modified files.

### Manual Verification
- **Registration**: Try entering more than 11 digits in the document field or more than 10 in the phone field. Verify the UI prevents it and the service receives the correct data.
- **History**: Delete an order and verify it disappears from the list and the database.
