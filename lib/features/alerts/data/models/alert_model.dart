import 'package:equatable/equatable.dart';

enum AlertSeverity { info, low, medium, high, critical }

class AlertModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String alertType;
  final String? batchId;
  final String? deliveryId;
  final String? collectionCentreId;
  final bool isResolved;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.alertType,
    this.batchId,
    this.deliveryId,
    this.collectionCentreId,
    required this.isResolved,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: use null-coalescing and try-catch for dates.
    // Avoid 'as String' crashes on nulls.
    final rawSeverity = (json['severity']?.toString() ?? 'info').toLowerCase();
    AlertSeverity parsedSeverity;
    switch (rawSeverity) {
      case 'critical':
        parsedSeverity = AlertSeverity.critical;
        break;
      case 'high':
        parsedSeverity = AlertSeverity.high;
        break;
      case 'medium':
        parsedSeverity = AlertSeverity.medium;
        break;
      case 'low':
        parsedSeverity = AlertSeverity.low;
        break;
      case 'info':
      default:
        parsedSeverity = AlertSeverity.info;
        break;
    }

    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Alert',
      message: json['message']?.toString() ?? '',
      severity: parsedSeverity,
      alertType: json['alert_type']?.toString() ?? 'system',
      batchId: json['batch_id']?.toString(),
      deliveryId: json['delivery_id']?.toString(),
      collectionCentreId: json['collection_centre_id']?.toString(),
      isResolved: json['is_resolved'] == true,
      createdAt: parsedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    severity,
    alertType,
    batchId,
    deliveryId,
    collectionCentreId,
    isResolved,
    createdAt,
  ];
}
