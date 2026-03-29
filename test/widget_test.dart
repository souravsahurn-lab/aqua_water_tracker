import 'package:flutter_test/flutter_test.dart';

import 'package:aqua_water_tracker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaApp());
    // Verify splash screen shows app name
    expect(find.text('Aqua'), findsOneWidget);
  });
}
