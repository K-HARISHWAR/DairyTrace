class Validators {
  static String? requiredText(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? passwordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? positiveDecimal(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number.isNaN || number.isInfinite || number <= 0) {
      return '${fieldName ?? 'Value'} must be a positive number';
    }
    return null;
  }

  static String? validPercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Percentage is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number.isNaN || number.isInfinite || number < 0 || number > 100) {
      return 'Enter a valid percentage (0-100)';
    }
    return null;
  }

  static String? numericBounds(String? value, {double? min, double? max, String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null || number.isNaN || number.isInfinite) {
      return 'Please enter a valid number';
    }
    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }
    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must be at most $max';
    }
    return null;
  }

  static String? phoneFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? uuid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Token is required';
    }
    final regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    if (!regex.hasMatch(value.trim())) {
      return 'Invalid token format';
    }
    return null;
  }

  static String? requiredDelayReason(String? reason) {
    if (reason == null || reason.trim().isEmpty) {
      return 'Delay reason is required';
    }
    if (reason.trim().length < 10) {
      return 'Please provide more details (min 10 chars)';
    }
    return null;
  }

  static String? requiredRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'Role association is required';
    }
    return null;
  }

  static String? dateOrdering(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) {
      return 'End date cannot be before start date';
    }
    return null;
  }

  static String? expectedDelivery(DateTime? pickup, DateTime? delivery) {
    if (pickup == null || delivery == null) return null;
    if (delivery.isBefore(pickup)) {
      return 'Expected delivery cannot be before expected pickup';
    }
    return null;
  }

  static String? requiredDate(DateTime? date, [String? fieldName]) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }
    return null;
  }
}
