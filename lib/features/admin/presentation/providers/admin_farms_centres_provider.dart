import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';
import '../../data/models/centre_model.dart';
import '../../data/repositories/centre_repository.dart';

class AdminFarmsFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearchQuery(String query) {
    state = query;
  }
}

final adminFarmsFilterProvider = NotifierProvider<AdminFarmsFilterNotifier, String>(
  AdminFarmsFilterNotifier.new,
);

class AdminPaginatedFarmsNotifier extends AsyncNotifier<List<FarmModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<FarmModel>> build() async {
    _page = 1;
    _hasMore = true;
    final query = ref.watch(adminFarmsFilterProvider);
    return _fetchFarms(page: 1, searchQuery: query);
  }

  Future<List<FarmModel>> _fetchFarms({
    required int page,
    required String searchQuery,
  }) async {
    final repository = ref.watch(farmRepositoryProvider);
    final results = await repository.getFarmsPaginated(
      collectionCentreId: null, // Global fetch
      searchQuery: searchQuery,
      page: page,
      pageSize: _pageSize,
    );

    _hasMore = results.length == _pageSize;
    return results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    final query = ref.read(adminFarmsFilterProvider);

    try {
      final nextFarms = await _fetchFarms(page: _page + 1, searchQuery: query);
      if (nextFarms.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextFarms]);
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
    final query = ref.read(adminFarmsFilterProvider);
    try {
      final farms = await _fetchFarms(page: 1, searchQuery: query);
      state = AsyncData(farms);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminPaginatedFarmsProvider = AsyncNotifierProvider.autoDispose<
  AdminPaginatedFarmsNotifier,
  List<FarmModel>
>(AdminPaginatedFarmsNotifier.new);

// ---------------- Centres Provider ----------------

class AdminCentresFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearchQuery(String query) {
    state = query;
  }
}

final adminCentresFilterProvider = NotifierProvider<AdminCentresFilterNotifier, String>(
  AdminCentresFilterNotifier.new,
);

class AdminPaginatedCentresNotifier extends AsyncNotifier<List<CentreModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<CentreModel>> build() async {
    _page = 1;
    _hasMore = true;
    final query = ref.watch(adminCentresFilterProvider);
    return _fetchCentres(page: 1, searchQuery: query);
  }

  Future<List<CentreModel>> _fetchCentres({
    required int page,
    required String searchQuery,
  }) async {
    final repository = ref.watch(centreRepositoryProvider);
    final results = await repository.getCentresPaginated(
      searchQuery: searchQuery,
      page: page,
      pageSize: _pageSize,
    );

    _hasMore = results.length == _pageSize;
    return results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    final query = ref.read(adminCentresFilterProvider);

    try {
      final nextCentres = await _fetchCentres(page: _page + 1, searchQuery: query);
      if (nextCentres.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextCentres]);
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
    final query = ref.read(adminCentresFilterProvider);
    try {
      final centres = await _fetchCentres(page: 1, searchQuery: query);
      state = AsyncData(centres);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminPaginatedCentresProvider = AsyncNotifierProvider.autoDispose<
  AdminPaginatedCentresNotifier,
  List<CentreModel>
>(AdminPaginatedCentresNotifier.new);
