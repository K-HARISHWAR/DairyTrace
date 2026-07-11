enum QualityResult {
  pending,
  pass,
  fail;

  factory QualityResult.fromString(String result) {
    switch (result) {
      case 'pass':
        return QualityResult.pass;
      case 'fail':
        return QualityResult.fail;
      case 'pending':
      default:
        return QualityResult.pending;
    }
  }

  String get value {
    switch (this) {
      case QualityResult.pass:
        return 'pass';
      case QualityResult.fail:
        return 'fail';
      case QualityResult.pending:
        return 'pending';
    }
  }
}
