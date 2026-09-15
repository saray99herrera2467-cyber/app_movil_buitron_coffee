import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('La aplicación inicia correctamente', (
      WidgetTester tester,
      ) async {
    // Construir la aplicación
    await tester.pumpWidget(const MyApp());

    // Verificar que aparece la pantalla de inicio de sesión
    expect(
      find.text('INICIO DE SESIÓN'),
      findsOneWidget,
    );

    // Verificar que aparece el campo de correo
    expect(
      find.text('Correo electrónico'),
      findsOneWidget,
    );

    // Verificar que aparece el campo de contraseña
    expect(
      find.text('Contraseña'),
      findsOneWidget,
    );

    // Verificar que aparece el botón de iniciar sesión
    expect(
      find.text('INICIAR SESIÓN'),
      findsOneWidget,
    );
  });
}