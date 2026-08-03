import 'package:flutter_test/flutter_test.dart';
import 'package:dairytrace/features/batches/data/models/batch_model.dart';
import 'package:dairytrace/features/alerts/data/models/alert_model.dart';
import 'package:dairytrace/core/enums/batch_stage.dart';
import 'package:dairytrace/core/enums/batch_status.dart';

void main() {
  group('Models', () {
    test('BatchModel parses JSON correctly', () {
      final json = {
        'id': 'test-batch-id',
        'batch_code': 'B-123',
        'public_token': 'test-token',
        'collection_centre_id': 'centre-1',
        'farm_id': 'farm-1',
        'quantity_litres': 150.5,
        'collection_time': '2023-10-01T12:00:00Z',
        'current_stage': 'chilling',
        'overall_status': 'accepted',
        'quality_status': 'passed',
        'created_by': 'user1',
        'created_at': '2023-10-01T12:00:00Z',
        'updated_at': '2023-10-01T12:00:00Z',
      };

      final batch = BatchModel.fromJson(json);

      expect(batch.id, 'test-batch-id');
      expect(batch.batchCode, 'B-123');
      expect(batch.quantityLitres, 150.5);
      expect(batch.currentStage, BatchStage.chilling);
      expect(batch.overallStatus, BatchStatus.accepted);
    });

    test('AlertModel parses JSON correctly', () {
      final json = {
        'id': 'alert-1',
        'title': 'Test Alert',
        'message': 'This is a test',
        'severity': 'high',
        'alert_type': 'quality',
        'is_resolved': false,
        'created_at': '2023-10-01T12:00:00Z'
      };

      final alert = AlertModel.fromJson(json);

      expect(alert.id, 'alert-1');
      expect(alert.title, 'Test Alert');
      expect(alert.severity, AlertSeverity.high);
      expect(alert.isResolved, false);
    });

    test('AlertModel handles unknown severity gracefully', () {
      final json = {
        'id': 'alert-2',
        'title': 'Unknown Severity Alert',
        'message': 'Test',
        'severity': 'unknown_weird_string',
        'alert_type': 'system',
        'is_resolved': true,
        'created_at': '2023-10-01T12:00:00Z'
      };

      final alert = AlertModel.fromJson(json);

      expect(alert.severity, AlertSeverity.info);
    });
  });
}
