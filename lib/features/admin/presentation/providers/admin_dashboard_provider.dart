import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';

final adminDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getDashboardStats();
});

final adminDailyVolumeProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, int>((ref, days) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getDailyCollectionVolume(days);
});

final adminRejectionTrendProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, int>((ref, days) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getRejectionTrend(days);
});
