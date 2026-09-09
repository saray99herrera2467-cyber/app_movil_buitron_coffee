# Walkthrough: Registration Restrictions and Order Management

I have implemented the requested restrictions for the registration process and added the ability to manage purchase history by deleting orders.

## Changes Made

### [Screens]

#### [registro_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/registro_screen.dart)
- **New Document Field**: Added a "Número de documento" text field, which was previously missing from the UI.
- **Character Restrictions**:
    - Document: Limited to **11 digits**.
    - Phone: Limited to **10 digits**.
- **Input Validation**: Configured the fields to use numeric keyboards and enforced the length limits both at the input level (maxLength) and during form submission validation.

#### [historial_screen.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/screens/historial_screen.dart)
- **Delete Functionality**: Each order card now features a trash icon button.
- **Safety Dialog**: Added a confirmation dialog to prevent accidental deletions.
- **Dynamic Refresh**: The list automatically refreshes after a successful deletion to provide immediate visual feedback.

### [Services]

#### [historial_service.dart](file:///C:/Users/leonc/AndroidStudioProjects/app_movil_buitron_coffee/lib/services/historial_service.dart)
- **Delete Logic**: Implemented `eliminarPedido` which handles the deletion in two steps:
    1. Removes associated items from `detalle_pedido`.
    2. Removes the main entry from the `pedido` table.
- **Robustness**: Replaced standard print statements with `debugPrint` for better production-ready logging.

## Verification Results

### Automated Tests
- Ran `flutter analyze`:
  - **Result**: `No issues found!`

### Manual Verification
- **Registration**: Verified that the document field stops at 11 characters and the phone field at 10.
- **Order Deletion**: Verified that deleting an order removes all its trace from the UI and the database.
