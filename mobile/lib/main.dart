import 'package:flutter/material.dart';

import 'screens/products_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DeliverPuyoApp());
}

class DeliverPuyoApp extends StatelessWidget {
  const DeliverPuyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliverPuyo Móvil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ProductsScreen(),
    );
  }
}
