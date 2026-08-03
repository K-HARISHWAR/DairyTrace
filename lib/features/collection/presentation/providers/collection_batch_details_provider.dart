import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tracking/data/models/tracking_event_model.dart';
import '../../../tracking/data/repositories/tracking_repository.dart';
import '../../../quality/data/models/quality_check_model.dart';
import '../../../quality/data/repositories/quality_repository.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';

final batchTrackingProvider = FutureProvider.autoDispose.family<List<TrackingEventModel>, String>((ref, batchId) async {
  return await ref.watch(trackingRepositoryProvider).getEventsForBatch(batchId);
});

final batchQualityProvider = FutureProvider.autoDispose.family<List<QualityCheckModel>, String>((ref, batchId) async {
  return await ref.watch(qualityRepositoryProvider).getChecksForBatch(batchId);
});

final batchFarmProvider = FutureProvider.autoDispose.family<FarmModel, String>((ref, farmId) async {
  return await ref.watch(farmRepositoryProvider).getFarmById(farmId);
});
