import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../batches/data/models/batch_model.dart';
import '../../../tracking/data/models/tracking_event_model.dart';
import '../../../tracking/data/repositories/tracking_repository.dart';
import '../../../quality/data/models/quality_check_model.dart';
import '../../../quality/data/repositories/quality_repository.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';

class BatchTrackingNotifier extends AutoDisposeFamilyAsyncNotifier<List<TrackingEventModel>, String> {
  @override
  FutureOr<List<TrackingEventModel>> build(String arg) async {
    return _fetchEvents(arg);
  }

  Future<List<TrackingEventModel>> _fetchEvents(String batchId) async {
    return await ref.watch(trackingRepositoryProvider).getEventsForBatch(batchId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final events = await _fetchEvents(arg);
      state = AsyncData(events);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final batchTrackingProvider = AutoDisposeAsyncNotifierProviderFamily<BatchTrackingNotifier, List<TrackingEventModel>, String>(BatchTrackingNotifier.new);

class BatchQualityNotifier extends AutoDisposeFamilyAsyncNotifier<List<QualityCheckModel>, String> {
  @override
  FutureOr<List<QualityCheckModel>> build(String arg) async {
    return _fetchQuality(arg);
  }

  Future<List<QualityCheckModel>> _fetchQuality(String batchId) async {
    return await ref.watch(qualityRepositoryProvider).getChecksForBatch(batchId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final checks = await _fetchQuality(arg);
      state = AsyncData(checks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final batchQualityProvider = AutoDisposeAsyncNotifierProviderFamily<BatchQualityNotifier, List<QualityCheckModel>, String>(BatchQualityNotifier.new);

class BatchFarmNotifier extends AutoDisposeFamilyAsyncNotifier<FarmModel, String> {
  @override
  FutureOr<FarmModel> build(String arg) async {
    return _fetchFarm(arg);
  }

  Future<FarmModel> _fetchFarm(String farmId) async {
    return await ref.watch(farmRepositoryProvider).getFarmById(farmId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final farm = await _fetchFarm(arg);
      state = AsyncData(farm);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final batchFarmProvider = AutoDisposeAsyncNotifierProviderFamily<BatchFarmNotifier, FarmModel, String>(BatchFarmNotifier.new);
