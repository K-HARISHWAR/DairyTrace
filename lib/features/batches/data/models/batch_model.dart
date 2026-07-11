import 'package:equatable/equatable.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/quality_result.dart';

class BatchModel extends Equatable {
  final String id;
  final String? batchCode;
  final String? qrToken;
  final String farmId;
  final double quantityLiters;
  final double? temperatureCelsius;
  final double? fatPercentage;
  final double? snfPercentage;
  final QualityResult qualityResult;
  final BatchStage stage;
  final String? notes;
  final DateTime createdAt;

  const BatchModel({
    required this.id,
    this.batchCode,
    this.qrToken,
    required this.farmId,
    required this.quantityLiters,
    this.temperatureCelsius,
    this.fatPercentage,
    this.snfPercentage,
    required this.qualityResult,
    required this.stage,
    this.notes,
    required this.createdAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      batchCode: json['batch_code'],
      qrToken: json['qr_token'],
      farmId: json['farm_id'],
      quantityLiters: (json['quantity_liters'] as num).toDouble(),
      temperatureCelsius: json['temperature_celsius'] != null ? (json['temperature_celsius'] as num).toDouble() : null,
      fatPercentage: json['fat_percentage'] != null ? (json['fat_percentage'] as num).toDouble() : null,
      snfPercentage: json['snf_percentage'] != null ? (json['snf_percentage'] as num).toDouble() : null,
      qualityResult: QualityResult.fromString(json['quality_result']),
      stage: BatchStage.fromString(json['stage']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        batchCode,
        qrToken,
        farmId,
        quantityLiters,
        temperatureCelsius,
        fatPercentage,
        snfPercentage,
        qualityResult,
        stage,
        notes,
        createdAt,
      ];
}
