enum DeliveryStatus {
  assigned,
  pickedUp,
  inTransit,
  delayed,
  delivered,
  cancelled;

  factory DeliveryStatus.fromString(String status) {
    switch (status) {
      case 'assigned': return DeliveryStatus.assigned;
      case 'picked_up': return DeliveryStatus.pickedUp;
      case 'in_transit': return DeliveryStatus.inTransit;
      case 'delayed': return DeliveryStatus.delayed;
      case 'delivered': return DeliveryStatus.delivered;
      case 'cancelled': return DeliveryStatus.cancelled;
      default: return DeliveryStatus.assigned;
    }
  }

  String get value {
    switch (this) {
      case DeliveryStatus.assigned: return 'assigned';
      case DeliveryStatus.pickedUp: return 'picked_up';
      case DeliveryStatus.inTransit: return 'in_transit';
      case DeliveryStatus.delayed: return 'delayed';
      case DeliveryStatus.delivered: return 'delivered';
      case DeliveryStatus.cancelled: return 'cancelled';
    }
  }
}
