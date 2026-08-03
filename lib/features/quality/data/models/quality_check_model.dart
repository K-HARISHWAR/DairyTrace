import 'package:equatable/equatable.dart';

class QualityCheckModel extends Equatable {
  final String id;
  final String batchId;
  final String checkpoint;
  final double? fatPercentage;
  final double? snfPercentage;
  final double? temperatureC;
  final bool? purityPassed;
  final String? manualResult;
  final String evaluatedResult;
  final String? remarks;
  final String checkedBy;
  final DateTime checkedAt;
  final DateTime createdAt;

  const QualityCheckModel({
    required this.id,
    required this.batchId,
    required this.checkpoint,
    this.fatPercentage,
    this.snfPercentage,
    this.temperatureC,
    this.purityPassed,
    this.manualResult,
    required this.evaluatedResult,
    this.remarks,
    required this.checkedBy,
    required this.checkedAt,
    required this.createdAt,
  });

  factory QualityCheckModel.fromJson(Map<String, dynamic> json) {
    return QualityCheckModel(
      id: json['id'],
      batchId: json['batch_id'],
      checkpoint: json['checkpoint'],
      fatPercentage: json['fat_percentage']?.toDouble(),
      snfPercentage: json['snf_percentage']?.toDouble(),
      temperatureC: json['temperature_c']?.toDouble(),
      purityPassed: json['purity_passed'],
      manualResult: json['manual_result'],
      evaluatedResult: json['evaluated_result'],
      remarks: json['remarks'],
      checkedBy: json['checked_by'],
      checkedAt: DateTime.parse(json['checked_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'checkpoint': checkpoint,
      'fat_percentage': fatPercentage,
      'snf_percentage': snfPercentage,
      'temperature_c': temperatureC,
      'purity_passed': purityPassed,
      'manual_result': manualResult,
      'evaluated_result': evaluatedResult,
      'remarks': remarks,
      'checked_by': checkedBy,
    };
  }

  @override
  List<Object?> get props => [
    id,
    batchId,
    checkpoint,
    fatPercentage,
    snfPercentage,
    temperatureC,
    purityPassed,
    manualResult,
    evaluatedResult,
    remarks,
    checkedBy,
    checkedAt,
    createdAt,
  ];
}
