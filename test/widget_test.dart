import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pokopia_guide/main.dart';
import 'package:pokopia_guide/providers/data_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DataProvider(),
        child: const PokopiaApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
