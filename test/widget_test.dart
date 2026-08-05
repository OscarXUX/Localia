import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:localia/providers/localia_provider.dart';
import 'package:localia/ui/tourist_screen.dart';

void main() {
  // void main() obligatoria agregada para solucionar el error de compilación.
  testWidgets('Prueba Funcional: Renderizado de saldo y ticker de la UI', (WidgetTester tester) async {
    // 1. Inicializamos el árbol de widgets envolviéndolo en el MultiProvider
    // para emular el arranque idéntico de la aplicación real.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaliaProvider()),
        ],
        child: const MaterialApp(
          home: TouristPortal(),
        ),
      ),
    );

    // 2. Forzamos un rediseño del frame para asegurar que el Provider cargue los datos por defecto.
    await tester.pumpAndSettle();

    // 3. PRUEBA DE UI: Validamos que la pantalla flotante tipo Apple renderice el saldo inicial.
    // El balance inicial por defecto configurado en tu LocaliaProvider es de $2500.00.
    expect(find.text('Saldo Coppel Pay'), findsOneWidget);
    expect(find.text('\$2500.00'), findsOneWidget);

    // 4. PRUEBA DE EVENTOS: Validamos que el Ticker de partidos del Mundial se pinte correctamente.
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });
}