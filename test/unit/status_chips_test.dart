import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dairytrace/core/widgets/status_chips.dart';
import 'package:dairytrace/core/enums/batch_status.dart';
import 'package:dairytrace/features/alerts/data/models/alert_model.dart';

void main() {
  group('Status Chips Widget Tests', () {
    testWidgets('BatchStatusChip renders correct label and color for accepted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BatchStatusChip(status: BatchStatus.accepted)),
        ),
      );

      expect(find.text('Accepted'), findsOneWidget);

      // Find the container to check color (it's the first Container inside StatusChipBase)
      final container = tester.firstWidget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      // We know Accepted uses Colors.green.withOpacity(0.1) for background
      expect(decoration.color, Colors.green.withOpacity(0.1));
    });

    testWidgets('AlertSeverityChip renders correct label for critical', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertSeverityChip(severity: AlertSeverity.critical),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
      expect(find.byIcon(Icons.report), findsOneWidget);
    });

    testWidgets('QualityStatusChip renders passed correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: QualityStatusChip(qualityStatus: 'passed')),
        ),
      );

      expect(find.text('Passed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
