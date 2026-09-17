import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplecalulator/main.dart';

void main() {
  Future<void> enter(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.ensureVisible(find.byKey(ValueKey('key_$key')));
      await tester.tap(find.byKey(ValueKey('key_$key')));
      await tester.pump();
    }
  }

  String result(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('result'))).data!;

  testWidgets('Supports all four operations', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (final example in [
      ['8', '+', '2', '=', '10'],
      ['8', '−', '2', '=', '6'],
      ['8', '×', '2', '=', '16'],
      ['8', '÷', '2', '=', '4'],
    ]) {
      await enter(tester, ['AC', ...example.take(4)]);
      expect(result(tester), example.last);
    }
  });

  testWidgets('Handles decimals, signs, deletion, and fresh entries', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await enter(tester, ['1', '.', '.', '5', '+', '2', '±', '=']);
    expect(result(tester), '-0.5');
    await enter(tester, ['9', '3', '⌫']);
    expect(result(tester), '9');
    await enter(tester, ['AC']);
    expect(result(tester), '0');
  });

  testWidgets('Chains operations and allows changing an operator', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await enter(tester, ['2', '+', '3', '×', '4', '=']);
    expect(result(tester), '20');
    await enter(tester, ['AC', '8', '+', '÷', '2', '=']);
    expect(result(tester), '4');
  });

  testWidgets('Recovers from division by zero', (tester) async {
    await tester.pumpWidget(const MyApp());
    await enter(tester, ['8', '÷', '0', '=']);
    expect(result(tester), 'Cannot divide by zero');
    await enter(tester, ['3', '+', '2', '=']);
    expect(result(tester), '5');
  });

  testWidgets('Fits a narrow screen and scrolls in landscape', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(640, 320);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('key_=')));
    expect(tester.takeException(), isNull);
  });
}

