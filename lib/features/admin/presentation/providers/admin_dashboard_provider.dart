import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';

class AdminDashboardStatsNotifier
    extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
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

final adminDashboardStatsProvider =
    AsyncNotifierProvider.autoDispose<
      AdminDashboardStatsNotifier,
      Map<String, dynamic>
    >(AdminDashboardStatsNotifier.new);

final adminDailyVolumeProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, int>((ref, days) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getDailyCollectionVolume(days);
});

final adminRejectionTrendProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, int>((ref, days) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getRejectionTrend(days);
});
