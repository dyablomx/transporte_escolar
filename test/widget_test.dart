import 'package:flutter_test/flutter_test.dart';
import 'package:trasporte_escolar/main.dart';

void main() {
  testWidgets('La aplicación muestra el título', (WidgetTester tester) async {
    await tester.pumpWidget(const TransporteEscolarApp());

    expect(find.text('Transporte Escolar'), findsOneWidget);
  });
}
