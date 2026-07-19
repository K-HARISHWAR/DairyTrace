import 'package:equatable/equatable.dart';

class TrackingEventModel extends Equatable {
  final String id;
  final String batchId;
  final String stage;
  final String eventType;
  final String status;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? remarks;
  final String createdBy;
  final DateTime occurredAt;

  const TrackingEventModel({
    required this.id,
    required this.batchId,
    required this.stage,
    required this.eventType,
    required this.status,
    this.locationName,
    this.latitude,
    this.longitude,
    this.remarks,
    required this.createdBy,
    required this.occurredAt,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'],
      batchId: json['batch_id'],
      stage: json['stage'],
      eventType: json['event_type'],
      status: json['status'],
      locationName: json['location_name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      remarks: json['remarks'],
      createdBy: json['created_by'],
      occurredAt: DateTime.parse(json['occurred_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'stage': stage,
      'event_type': eventType,
      'status': status,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
      'created_by': createdBy,
      'occurred_at': occurredAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        batchId,
        stage,
        eventType,
        status,
        locationName,
        latitude,
        longitude,
        remarks,
        createdBy,
        occurredAt,
      ];
}
