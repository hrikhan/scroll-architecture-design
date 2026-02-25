import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scroll/core/storage/shared_prefs_provider.dart';
import 'package:scroll/core/storage/shared_prefs_service.dart';
import 'package:scroll/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows login screen when there is no saved session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsServiceProvider.overrideWithValue(SharedPrefsService(prefs)),
        ],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.text('FakeStore Login'), findsOneWidget);
  });
}
