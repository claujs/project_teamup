

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_up/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    expect(() => const ProviderScope(child: MyApp()), returnsNormally);
  });
}
