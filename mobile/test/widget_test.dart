import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliverpuyo_mobile/theme/app_theme.dart';
import 'package:deliverpuyo_mobile/widgets/app_primary_button.dart';
import 'package:deliverpuyo_mobile/widgets/category_filter_chip.dart';
import 'package:deliverpuyo_mobile/widgets/product_card.dart';
import 'package:deliverpuyo_mobile/widgets/state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  group('AppPrimaryButton', () {
    testWidgets('renders normal state', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          AppPrimaryButton(
            text: 'GUARDAR',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      expect(find.text('GUARDAR'), findsOneWidget);
      await tester.tap(find.byType(AppPrimaryButton));
      expect(pressed, isTrue);
    });

    testWidgets('renders loading state and disables action', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          AppPrimaryButton(
            text: 'GUARDAR',
            loading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppPrimaryButton));
      expect(pressed, isFalse);
    });

    testWidgets('renders disabled state', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          AppPrimaryButton(
            text: 'GUARDAR',
            enabled: false,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(AppPrimaryButton));
      expect(pressed, isFalse);
    });
  });

  group('StateView', () {
    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StateView(
            type: StateViewType.loading,
            message: 'Cargando productos...',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando productos...'), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StateView(
            type: StateViewType.empty,
            message: 'No hay productos disponibles en este momento.',
          ),
        ),
      );

      expect(
        find.text('No hay productos disponibles en este momento.'),
        findsOneWidget,
      );
      expect(find.byType(AppPrimaryButton), findsNothing);
    });

    testWidgets('renders error state with retry action', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          StateView(
            type: StateViewType.error,
            message: 'No fue posible conectarse con el servidor.',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      );

      expect(
        find.text('No fue posible conectarse con el servidor.'),
        findsOneWidget,
      );
      expect(find.text('REINTENTAR'), findsOneWidget);
      await tester.tap(find.text('REINTENTAR'));
      expect(retried, isTrue);
    });

    testWidgets('exposes semantic label for errors', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const StateView(
            type: StateViewType.error,
            message: 'No fue posible conectarse con el servidor.',
          ),
        ),
      );

      final stateSemantics = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'Estado error. No fue posible conectarse con el servidor.',
        ),
      );
      expect(stateSemantics, isNotEmpty);
      semantics.dispose();
    });
  });

  group('ProductCard', () {
    testWidgets('renders product data', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ProductCard(
            name: 'Café amazónico',
            price: 2.5,
            stock: 8,
            category: 'Bebidas',
          ),
        ),
      );

      expect(find.text('Café amazónico'), findsOneWidget);
      expect(find.text(r'$2.50'), findsOneWidget);
      expect(find.text('Bebidas'), findsOneWidget);
      expect(find.text('8 disponibles'), findsOneWidget);
    });

    testWidgets('calls onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          ProductCard(
            name: 'Empanada',
            price: 1.25,
            stock: 3,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });

    testWidgets('exposes product semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(const ProductCard(name: 'Jugo natural', price: 1.5, stock: 0)),
      );

      final productSemantics = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  r'Producto Jugo natural, sin categoría, precio $1.50, Sin stock',
        ),
      );
      expect(productSemantics, isNotEmpty);
      semantics.dispose();
    });
  });

  group('CategoryFilterChip', () {
    testWidgets('renders selected category and calls callback', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        _wrap(
          CategoryFilterChip(
            label: 'Bebidas',
            selected: false,
            onSelected: (value) {
              selected = value;
            },
          ),
        ),
      );

      expect(find.text('Bebidas'), findsOneWidget);
      await tester.tap(find.byType(CategoryFilterChip));
      expect(selected, isTrue);
    });

    testWidgets('exposes selected semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          CategoryFilterChip(
            label: 'Postres',
            selected: true,
            onSelected: (_) {},
          ),
        ),
      );

      final chipSemantics = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Postres, filtro seleccionado',
        ),
      );
      expect(chipSemantics, isNotEmpty);
      semantics.dispose();
    });
  });
}
