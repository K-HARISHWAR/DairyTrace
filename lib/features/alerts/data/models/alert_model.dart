import 'package:equatable/equatable.dart';
import '../../../../core/enums/alert_severity.dart';

class AlertModel extends Equatable {
  final String id;
  final String? batchId;
  final String? deliveryId;
  final String? collectionCentreId;
  final String alertType;
  final String title;
  final String message;
  final AlertSeverity severity;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertModel({
    required this.id,
    this.batchId,
    this.deliveryId,
    this.collectionCentreId,
    required this.alertType,
    required this.title,
    required this.message,
    required this.severity,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      batchId: json['batch_id'],
      deliveryId: json['delivery_id'],
      collectionCentreId: json['collection_centre_id'],
      alertType: json['alert_type'],
      title: json['title'],
      message: json['message'],
      severity: AlertSeverity.fromString(json['severity']),
      isResolved: json['is_resolved'] ?? false,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      resolvedBy: json['resolved_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'delivery_id': deliveryId,
      'collection_centre_id': collectionCentreId,
      'alert_type': alertType,
      'title': title,
      'message': message,
      'severity': severity.value,
      'is_resolved': isResolved,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        batchId,
        deliveryId,
        collectionCentreId,
        alertType,
        title,
        message,
        severity,
        isResolved,
        resolvedAt,
        resolvedBy,
        createdAt,
        updatedAt,
      ];
}
