enum BatchStage {
  collection,
  chilling,
  processing,
  packaging,
  distribution,
  delivered;

  factory BatchStage.fromString(String stage) {
    switch (stage) {
      case 'collection': return BatchStage.collection;
      case 'chilling': return BatchStage.chilling;
      case 'processing': return BatchStage.processing;
      case 'packaging': return BatchStage.packaging;
      case 'distribution': return BatchStage.distribution;
      case 'delivered': return BatchStage.delivered;
      default: return BatchStage.collection;
    }
  }

  String get value {
    switch (this) {
      case BatchStage.collection: return 'collection';
      case BatchStage.chilling: return 'chilling';
      case BatchStage.processing: return 'processing';
      case BatchStage.packaging: return 'packaging';
      case BatchStage.distribution: return 'distribution';
      case BatchStage.delivered: return 'delivered';
    }
  }
}
