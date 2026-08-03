enum QualityStatus {
  pending,
  passed,
  failed;

  factory QualityStatus.fromString(String status) {
    switch (status) {
      case 'pending':
        return QualityStatus.pending;
      case 'passed':
        return QualityStatus.passed;
      case 'failed':
        return QualityStatus.failed;
      default:
        return QualityStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case QualityStatus.pending:
        return 'pending';
      case QualityStatus.passed:
        return 'passed';
      case QualityStatus.failed:
        return 'failed';
    }
  }
}
