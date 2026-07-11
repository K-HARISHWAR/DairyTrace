enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  factory AlertSeverity.fromString(String severity) {
    switch (severity) {
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      case 'low':
      default:
        return AlertSeverity.low;
    }
  }

  String get value {
    switch (this) {
      case AlertSeverity.low:
        return 'low';
      case AlertSeverity.medium:
        return 'medium';
      case AlertSeverity.high:
        return 'high';
      case AlertSeverity.critical:
        return 'critical';
    }
  }
}
