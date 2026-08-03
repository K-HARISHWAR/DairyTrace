import 'package:equatable/equatable.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';
import '../../../../core/enums/quality_result.dart';

class BatchModel extends Equatable {
  final String id;
  final String batchCode;
  final String publicToken;
  final String farmId;
  final String collectionCentreId;
  final double quantityLitres;
  final DateTime collectionTime;
  final BatchStage currentStage;
  final BatchStatus overallStatus;
  final QualityStatus qualityStatus;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BatchModel({
    required this.id,
    required this.batchCode,
    required this.publicToken,
    required this.farmId,
    required this.collectionCentreId,
    required this.quantityLitres,
    required this.collectionTime,
    required this.currentStage,
    required this.overallStatus,
    required this.qualityStatus,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      batchCode: json['batch_code'] ?? '',
      publicToken: json['public_token'] ?? '',
      farmId: json['farm_id'],
      collectionCentreId: json['collection_centre_id'],
      quantityLitres: (json['quantity_litres'] as num).toDouble(),
      collectionTime: DateTime.parse(json['collection_time']),
      currentStage: BatchStage.fromString(json['current_stage']),
      overallStatus: BatchStatus.fromString(json['overall_status']),
      qualityStatus: QualityStatus.fromString(json['quality_status']),
      notes: json['notes'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_code': batchCode,
      'public_token': publicToken,
      'farm_id': farmId,
      'collection_centre_id': collectionCentreId,
      'quantity_litres': quantityLitres,
      'collection_time': collectionTime.toIso8601String(),
      'current_stage': currentStage.value,
      'overall_status': overallStatus.value,
      'quality_status': qualityStatus.value,
      'notes': notes,
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
    id,
    batchCode,
    publicToken,
    farmId,
    collectionCentreId,
    quantityLitres,
    collectionTime,
    currentStage,
    overallStatus,
    qualityStatus,
    notes,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
