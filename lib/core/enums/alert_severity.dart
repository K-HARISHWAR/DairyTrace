enum AlertSeverity {
  info,
  low,
  medium,
  high,
  critical;

  factory AlertSeverity.fromString(String severity) {
    switch (severity) {
      case 'info': return AlertSeverity.info;
      case 'low': return AlertSeverity.low;
      case 'medium': return AlertSeverity.medium;
      case 'high': return AlertSeverity.high;
      case 'critical': return AlertSeverity.critical;
      default: return AlertSeverity.info;
    }
  }

  String get value {
    switch (this) {
      case AlertSeverity.info: return 'info';
      case AlertSeverity.low: return 'low';
      case AlertSeverity.medium: return 'medium';
      case AlertSeverity.high: return 'high';
      case AlertSeverity.critical: return 'critical';
    }
  }
}
