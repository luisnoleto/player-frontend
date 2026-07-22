// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/api_client.dart';
import 'package:frontend/core/session_provider.dart';
import 'package:frontend/screens/auth/login_page.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  testWidgets('login screen is displayed', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final session = SessionProvider(AuthService(apiClient), apiClient);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: session,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);

    final campos = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(campos[0].autofillHints, contains(AutofillHints.username));
    expect(campos[1].autofillHints, contains(AutofillHints.password));
  });
}
