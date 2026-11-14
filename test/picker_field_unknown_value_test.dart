import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchmaker_app/shared/widgets/picker_field.dart';

void main() {
  testWidgets('PickerField with a value not present in options does not crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PickerField(
            label: 'Status',
            value: 'hot', // simulates a stale enums cache that predates the hot/paid rollout
            options: const {'new': 'New', 'contacted': 'Follow-up'},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
