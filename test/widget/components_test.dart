import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dairytrace/core/widgets/async_state_handler.dart';

void main() {
  group('Components Widget Tests', () {
    testWidgets('AsyncStateHandler shows loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateHandler<String>(
              value: const AsyncLoading(),
              dataBuilder: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AsyncStateHandler shows data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateHandler<String>(
              value: const AsyncData('Success Data'),
              dataBuilder: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('Success Data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('AsyncStateHandler shows empty state for null data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateHandler<String?>(
              value: const AsyncData(null),
              dataBuilder: (data) => Text(data ?? ''),
              emptyMessage: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('AsyncStateHandler shows error state with retry button', (
      WidgetTester tester,
    ) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateHandler<String>(
              value: AsyncError('Network Error', StackTrace.empty),
              dataBuilder: (data) => Text(data),
              onRetry: () {
                retryClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Unable to connect or load data.'), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);

      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      expect(retryClicked, isTrue);
    });
  });
}
