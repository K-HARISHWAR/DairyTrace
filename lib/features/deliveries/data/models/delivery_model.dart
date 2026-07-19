import 'package:equatable/equatable.dart';
import '../../../../core/enums/delivery_status.dart';

class DeliveryModel extends Equatable {
  final String id;
  final String batchId;
  final String distributorOrganisationId;
  final String assignedTo;
  final String? vehicleNumber;
  final String? driverName;
  final String? driverPhone;
  final DateTime assignedAt;
  final DateTime? expectedPickupAt;
  final DateTime? actualPickupAt;
  final DateTime? expectedDeliveryAt;
  final DateTime? actualDeliveryAt;
  final DeliveryStatus status;
  final String? delayReason;
  final String? deliveryNotes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryModel({
    required this.id,
    required this.batchId,
    required this.distributorOrganisationId,
    required this.assignedTo,
    this.vehicleNumber,
    this.driverName,
    this.driverPhone,
    required this.assignedAt,
    this.expectedPickupAt,
    this.actualPickupAt,
    this.expectedDeliveryAt,
    this.actualDeliveryAt,
    required this.status,
    this.delayReason,
    this.deliveryNotes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      batchId: json['batch_id'],
      distributorOrganisationId: json['distributor_organisation_id'],
      assignedTo: json['assigned_to'],
      vehicleNumber: json['vehicle_number'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      assignedAt: DateTime.parse(json['assigned_at']),
      expectedPickupAt: json['expected_pickup_at'] != null ? DateTime.parse(json['expected_pickup_at']) : null,
      actualPickupAt: json['actual_pickup_at'] != null ? DateTime.parse(json['actual_pickup_at']) : null,
      expectedDeliveryAt: json['expected_delivery_at'] != null ? DateTime.parse(json['expected_delivery_at']) : null,
      actualDeliveryAt: json['actual_delivery_at'] != null ? DateTime.parse(json['actual_delivery_at']) : null,
      status: DeliveryStatus.fromString(json['status']),
      delayReason: json['delay_reason'],
      deliveryNotes: json['delivery_notes'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'distributor_organisation_id': distributorOrganisationId,
      'assigned_to': assignedTo,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'assigned_at': assignedAt.toIso8601String(),
      'expected_pickup_at': expectedPickupAt?.toIso8601String(),
      'actual_pickup_at': actualPickupAt?.toIso8601String(),
      'expected_delivery_at': expectedDeliveryAt?.toIso8601String(),
      'actual_delivery_at': actualDeliveryAt?.toIso8601String(),
      'status': status.value,
      'delay_reason': delayReason,
      'delivery_notes': deliveryNotes,
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        batchId,
        distributorOrganisationId,
        assignedTo,
        vehicleNumber,
        driverName,
        driverPhone,
        assignedAt,
        expectedPickupAt,
        actualPickupAt,
        expectedDeliveryAt,
        actualDeliveryAt,
        status,
        delayReason,
        deliveryNotes,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
