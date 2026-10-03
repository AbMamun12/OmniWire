import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transfer_pro/main.dart';

void main() {
  testWidgets('TransferProApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TransferProApp());
    await tester.pump();

    expect(find.text('TRANSFER PRO'), findsOneWidget);
    expect(find.text('TX SENDER'), findsOneWidget);
    expect(find.text('RX RECEIVER'), findsOneWidget);
  });
}
