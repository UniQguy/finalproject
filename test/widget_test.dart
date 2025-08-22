import 'package:finalproject/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finalproject/main.dart';

void main() {
  testWidgets('App loads and shows DemoTrader text', (WidgetTester tester) async {
    // Build your app and trigger a frame.
    await tester.pumpWidget(DemoApp());


    // Verify that the text 'DemoTrader' is found,
    // which is present on your splash screen.
    expect(find.text('DemoTrader'), findsOneWidget);

    // The default counter increment test is not applicable
    // since your app does not have a counter and a '+' button.
    // You can write other relevant widget tests based on your UI.
  });
}
