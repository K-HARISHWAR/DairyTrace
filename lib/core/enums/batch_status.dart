enum BatchStatus {
  pendingQuality,
  accepted,
  rejected,
  inProgress,
  delayed,
  spoiled,
  delivered;

  factory BatchStatus.fromString(String status) {
    switch (status) {
      case 'pending_quality':
        return BatchStatus.pendingQuality;
      case 'accepted':
        return BatchStatus.accepted;
      case 'rejected':
        return BatchStatus.rejected;
      case 'in_progress':
        return BatchStatus.inProgress;
      case 'delayed':
        return BatchStatus.delayed;
      case 'spoiled':
        return BatchStatus.spoiled;
      case 'delivered':
        return BatchStatus.delivered;
      default:
        return BatchStatus.pendingQuality;
    }
  }

  String get value {
    switch (this) {
      case BatchStatus.pendingQuality:
        return 'pending_quality';
      case BatchStatus.accepted:
        return 'accepted';
      case BatchStatus.rejected:
        return 'rejected';
      case BatchStatus.inProgress:
        return 'in_progress';
      case BatchStatus.delayed:
        return 'delayed';
      case BatchStatus.spoiled:
        return 'spoiled';
      case BatchStatus.delivered:
        return 'delivered';
    }
  }
}
