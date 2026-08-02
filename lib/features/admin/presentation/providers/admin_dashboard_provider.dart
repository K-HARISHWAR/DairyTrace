import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';

class AdminDashboardStatsNotifier extends AutoDisposeAsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final repository = ref.watch(adminRepositoryProvider);
    return await repository.getDashboardStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final stats = await _fetchStats();
      state = AsyncData(stats);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminDashboardStatsProvider = AutoDisposeAsyncNotifierProvider<AdminDashboardStatsNotifier, Map<String, dynamic>>(AdminDashboardStatsNotifier.new);

class AdminDailyVolumeNotifier extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, int> {
  @override
  FutureOr<List<Map<String, dynamic>>> build(int arg) async {
    return _fetchVolume(arg);
  }

  Future<List<Map<String, dynamic>>> _fetchVolume(int days) async {
    final repository = ref.watch(adminRepositoryProvider);
    return await repository.getDailyCollectionVolume(days);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final volume = await _fetchVolume(arg);
      state = AsyncData(volume);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminDailyVolumeProvider = AutoDisposeAsyncNotifierProviderFamily<AdminDailyVolumeNotifier, List<Map<String, dynamic>>, int>(AdminDailyVolumeNotifier.new);

class AdminRejectionTrendNotifier extends AutoDisposeFamilyAsyncNotifier<List<Map<String, dynamic>>, int> {
  @override
  FutureOr<List<Map<String, dynamic>>> build(int arg) async {
    return _fetchTrend(arg);
  }

  Future<List<Map<String, dynamic>>> _fetchTrend(int days) async {
    final repository = ref.watch(adminRepositoryProvider);
    return await repository.getRejectionTrend(days);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final trend = await _fetchTrend(arg);
      state = AsyncData(trend);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminRejectionTrendProvider = AutoDisposeAsyncNotifierProviderFamily<AdminRejectionTrendNotifier, List<Map<String, dynamic>>, int>(AdminRejectionTrendNotifier.new);
