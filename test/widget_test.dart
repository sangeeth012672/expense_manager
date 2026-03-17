// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/main.dart';
import 'package:flutter_app/repositories/auth_repository.dart';
import 'package:flutter_app/repositories/category_repository.dart';
import 'package:flutter_app/repositories/transaction_repository.dart';
import 'package:flutter_app/repositories/sync_repository.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final client = http.Client();
    final authRepository = AuthRepository(client: client);
    final categoryRepository = CategoryRepository();
    final transactionRepository = TransactionRepository();
    final syncRepository = SyncRepository(
       client: client,
       authRepository: authRepository,
       categoryRepository: categoryRepository,
       transactionRepository: transactionRepository,
    );
      
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      authRepository: authRepository,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
      syncRepository: syncRepository,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
