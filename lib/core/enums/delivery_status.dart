enum DeliveryStatus {
  pending,
  inTransit,
  delayed,
  delivered;

  factory DeliveryStatus.fromString(String status) {
    switch (status) {
      case 'in_transit':
        return DeliveryStatus.inTransit;
      case 'delayed':
        return DeliveryStatus.delayed;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'pending':
      default:
        return DeliveryStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.inTransit:
        return 'in_transit';
      case DeliveryStatus.delayed:
        return 'delayed';
      case DeliveryStatus.delivered:
        return 'delivered';
    }
  }
}
