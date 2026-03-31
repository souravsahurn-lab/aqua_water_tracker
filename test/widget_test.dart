import 'package:flutter_test/flutter_test.dart';

import 'package:aqua_water_tracker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaApp(isSetupComplete: false));
    // Verify onboarding shows something (Aqua app name usually present in theme/appbar)
    expect(find.byType(AquaApp), findsOneWidget);
  });
}
