import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/data/models/profile_model.dart';
import '../../data/repositories/admin_repository.dart';

class UserFilterArgs {
  final String searchQuery;

  const UserFilterArgs({this.searchQuery = ''});

  UserFilterArgs copyWith({String? searchQuery}) {
    return UserFilterArgs(searchQuery: searchQuery ?? this.searchQuery);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFilterArgs &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => searchQuery.hashCode;
}

class UserFilterNotifier extends Notifier<UserFilterArgs> {
  @override
  UserFilterArgs build() => const UserFilterArgs();

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final userFilterProvider = NotifierProvider<UserFilterNotifier, UserFilterArgs>(
  UserFilterNotifier.new,
);

class AdminUsersNotifier extends AsyncNotifier<List<ProfileModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<ProfileModel>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchUsers(page: 1);
  }

  Future<List<ProfileModel>> _fetchUsers({required int page}) async {
    final args = ref.watch(userFilterProvider);
    final repository = ref.watch(adminRepositoryProvider);
    final results = await repository.getUsersPaginated(
      searchQuery: args.searchQuery,
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
      final nextUsers = await _fetchUsers(page: _page + 1);
      if (nextUsers.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextUsers]);
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
      final users = await _fetchUsers(page: 1);
      state = AsyncData(users);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminUsersProvider =
    AsyncNotifierProvider.autoDispose<AdminUsersNotifier, List<ProfileModel>>(
      AdminUsersNotifier.new,
    );

class ActiveCentresNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchCentres();
  }

  Future<List<Map<String, dynamic>>> _fetchCentres() async {
    return await ref.watch(adminRepositoryProvider).getActiveCentres();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final centres = await _fetchCentres();
      state = AsyncData(centres);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final activeCentresProvider =
    AsyncNotifierProvider.autoDispose<
      ActiveCentresNotifier,
      List<Map<String, dynamic>>
    >(ActiveCentresNotifier.new);

class ActiveDistributorsNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchDistributors();
  }

  Future<List<Map<String, dynamic>>> _fetchDistributors() async {
    return await ref.watch(adminRepositoryProvider).getActiveDistributors();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final distributors = await _fetchDistributors();
      state = AsyncData(distributors);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final activeDistributorsProvider =
    AsyncNotifierProvider.autoDispose<
      ActiveDistributorsNotifier,
      List<Map<String, dynamic>>
    >(ActiveDistributorsNotifier.new);
