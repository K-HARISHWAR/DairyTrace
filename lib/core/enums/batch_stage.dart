enum BatchStage {
  registered,
  qualityCheck,
  accepted,
  rejected,
  inTransit,
  delayed,
  delivered;

  factory BatchStage.fromString(String stage) {
    switch (stage) {
      case 'registered':
        return BatchStage.registered;
      case 'quality_check':
        return BatchStage.qualityCheck;
      case 'accepted':
        return BatchStage.accepted;
      case 'rejected':
        return BatchStage.rejected;
      case 'in_transit':
        return BatchStage.inTransit;
      case 'delayed':
        return BatchStage.delayed;
      case 'delivered':
        return BatchStage.delivered;
      default:
        return BatchStage.registered;
    }
  }

  String get value {
    switch (this) {
      case BatchStage.registered:
        return 'registered';
      case BatchStage.qualityCheck:
        return 'quality_check';
      case BatchStage.accepted:
        return 'accepted';
      case BatchStage.rejected:
        return 'rejected';
      case BatchStage.inTransit:
        return 'in_transit';
      case BatchStage.delayed:
        return 'delayed';
      case BatchStage.delivered:
        return 'delivered';
    }
  }
}
