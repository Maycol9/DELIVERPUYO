import 'package:deliverpuyo_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows DeliverPuyo API test screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliverPuyoApp());

    expect(find.text('DeliverPuyo Móvil'), findsWidgets);
    expect(find.text('PROBAR CONEXIÓN CON API'), findsOneWidget);
  });
}
