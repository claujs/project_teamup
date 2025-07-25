import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_up/shared/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('should display loading indicator', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoadingWidget())),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading indicator with message', (
      WidgetTester tester,
    ) async {
      // Arrange
      const message = 'Loading data...';

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: LoadingWidget(message: message)),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display custom size loading indicator', (
      WidgetTester tester,
    ) async {
      // Arrange
      const size = 50.0;

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: LoadingWidget(size: size)),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(size));
      expect(sizedBox.height, equals(size));
    });

    testWidgets('should not display message when not provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoadingWidget())),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });
}
