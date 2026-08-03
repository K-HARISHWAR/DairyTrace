import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alert_repository.dart';

class AlertsNotifier extends AsyncNotifier<List<AlertModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<AlertModel>> build() async {
    _page = 1;
    _hasMore = true;

    // Listen to real-time alerts for notifications
    final user = ref.watch(authStateProvider).value;
    if (user != null) {
      final sub = ref.watch(alertRepositoryProvider).watchAlerts().listen((
        dataList,
      ) {
        // Just show notifications for new critical/high ones that pop in real-time
        // We could also call refresh() here if we want the list to auto-update
      });
      ref.onDispose(() => sub.cancel());
    }

    return _fetchAlerts(page: 1);
  }

  Future<List<AlertModel>> _fetchAlerts({required int page}) async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final results = await ref
        .watch(alertRepositoryProvider)
        .getUnresolvedAlerts(
          page: page,
          pageSize: _pageSize,
          collectionCentreId: user.collectionCentreId,
        );

    _hasMore = results.length == _pageSize;
    return results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    try {
      final nextAlerts = await _fetchAlerts(page: _page + 1);
      if (nextAlerts.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextAlerts]);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasMore = true;
    try {
      final alerts = await _fetchAlerts(page: 1);
      state = AsyncData(alerts);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final alertsProvider =
    AsyncNotifierProvider.autoDispose<AlertsNotifier, List<AlertModel>>(
      AlertsNotifier.new,
    );
