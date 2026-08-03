import 'package:flutter_test/flutter_test.dart';
import 'package:dairytrace/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('requiredText validates properly', () {
      expect(Validators.requiredText('hello'), isNull);
      expect(Validators.requiredText(''), 'This field is required');
      expect(Validators.requiredText(null), 'This field is required');
      expect(Validators.requiredText('', 'Name'), 'Name is required');
    });

    test('email validates properly', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('positiveDecimal validates properly', () {
      expect(Validators.positiveDecimal('10.5'), isNull);
      expect(
        Validators.positiveDecimal('0'),
        'Value must be a positive number',
      );
      expect(
        Validators.positiveDecimal('-5'),
        'Value must be a positive number',
      );
      expect(Validators.positiveDecimal('abc'), 'Please enter a valid number');
      expect(Validators.positiveDecimal(''), 'This field is required');
    });

    test('validPercentage validates properly', () {
      expect(Validators.validPercentage('50'), isNull);
      expect(Validators.validPercentage('0'), isNull);
      expect(Validators.validPercentage('100'), isNull);
      expect(
        Validators.validPercentage('101'),
        'Enter a valid percentage (0-100)',
      );
      expect(
        Validators.validPercentage('-1'),
        'Enter a valid percentage (0-100)',
      );
      expect(Validators.validPercentage('abc'), 'Please enter a valid number');
    });

    test('uuid validates properly', () {
      expect(Validators.uuid('123e4567-e89b-12d3-a456-426614174000'), isNull);
      expect(Validators.uuid('invalid-uuid'), 'Invalid token format');
      expect(Validators.uuid(''), 'Token is required');
    });

    test('dateOrdering validates properly', () {
      final now = DateTime.now();
      expect(
        Validators.dateOrdering(now, now.add(const Duration(days: 1))),
        isNull,
      );
      expect(
        Validators.dateOrdering(now, now.subtract(const Duration(days: 1))),
        'End date cannot be before start date',
      );
    });
  });
}
