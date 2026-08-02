import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';

class FarmFilterArgs {
  final String searchQuery;
  final bool? isActive;

  const FarmFilterArgs({
    this.searchQuery = '',
    this.isActive,
  });

  FarmFilterArgs copyWith({
    String? searchQuery,
    bool? isActive,
  }) {
    return FarmFilterArgs(
      searchQuery: searchQuery ?? this.searchQuery,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmFilterArgs &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          isActive == other.isActive;

  @override
  int get hashCode => searchQuery.hashCode ^ (isActive?.hashCode ?? 0);
}

// Notifier for preserving filters
class FarmFilterNotifier extends Notifier<FarmFilterArgs> {
  @override
  FarmFilterArgs build() => const FarmFilterArgs();

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateIsActiveFilter(bool? isActive) {
    state = state.copyWith(isActive: isActive);
  }
}

final farmFilterProvider = NotifierProvider<FarmFilterNotifier, FarmFilterArgs>(FarmFilterNotifier.new);

// AsyncNotifier for fetching data based on filters
class PaginatedFarmsNotifier extends AutoDisposeAsyncNotifier<List<FarmModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<FarmModel>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchFarms(page: 1);
  }

  Future<List<FarmModel>> _fetchFarms({required int page}) async {
    final args = ref.watch(farmFilterProvider);
    final user = ref.watch(authStateProvider).value;
    
    if (user == null || user.collectionCentreId == null) return [];

    final repository = ref.watch(farmRepositoryProvider);
    final results = await repository.getFarmsPaginated(
      collectionCentreId: user.collectionCentreId!,
      searchQuery: args.searchQuery,
      isActive: args.isActive,
      page: page,
      pageSize: _pageSize,
    );
    
    _hasMore = results.length == _pageSize;
    return results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    
    try {
      final nextFarms = await _fetchFarms(page: _page + 1);
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
    try {
      final farms = await _fetchFarms(page: 1);
      state = AsyncData(farms);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final paginatedFarmsProvider = AutoDisposeAsyncNotifierProvider<PaginatedFarmsNotifier, List<FarmModel>>(PaginatedFarmsNotifier.new);
