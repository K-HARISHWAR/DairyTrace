import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../batches/data/models/batch_model.dart';
import '../../../batches/data/repositories/batch_repository.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';

class AdminBatchFilterArgs {
  final String searchQuery;
  final BatchStage? stageFilter;
  final BatchStatus? statusFilter;

  const AdminBatchFilterArgs({
    this.searchQuery = '',
    this.stageFilter,
    this.statusFilter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminBatchFilterArgs &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          stageFilter == other.stageFilter &&
          statusFilter == other.statusFilter;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      (stageFilter?.hashCode ?? 0) ^
      (statusFilter?.hashCode ?? 0);
}

class AdminBatchFilterNotifier extends Notifier<AdminBatchFilterArgs> {
  @override
  AdminBatchFilterArgs build() => const AdminBatchFilterArgs();

  void updateSearchQuery(String query) {
    state = AdminBatchFilterArgs(
      searchQuery: query,
      stageFilter: state.stageFilter,
      statusFilter: state.statusFilter,
    );
  }

  void updateStageFilter(BatchStage? stage) {
    state = AdminBatchFilterArgs(
      searchQuery: state.searchQuery,
      stageFilter: stage,
      statusFilter: state.statusFilter,
    );
  }

  void updateStatusFilter(BatchStatus? status) {
    state = AdminBatchFilterArgs(
      searchQuery: state.searchQuery,
      stageFilter: state.stageFilter,
      statusFilter: status,
    );
  }
}

final adminBatchFilterProvider =
    NotifierProvider<AdminBatchFilterNotifier, AdminBatchFilterArgs>(
      AdminBatchFilterNotifier.new,
    );

class AdminPaginatedBatchesNotifier extends AsyncNotifier<List<BatchModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<BatchModel>> build() async {
    _page = 1;
    _hasMore = true;
    final args = ref.watch(adminBatchFilterProvider);
    return _fetchBatches(page: 1, args: args);
  }

  Future<List<BatchModel>> _fetchBatches({
    required int page,
    required AdminBatchFilterArgs args,
  }) async {
    final repository = ref.watch(batchRepositoryProvider);
    final results = await repository.getBatchesPaginated(
      collectionCentreId: null, // Fetch globally
      searchQuery: args.searchQuery,
      stageFilter: args.stageFilter,
      statusFilter: args.statusFilter,
      page: page,
      pageSize: _pageSize,
    );

    _hasMore = results.length == _pageSize;
    return results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    final args = ref.read(adminBatchFilterProvider);

    try {
      final nextBatches = await _fetchBatches(page: _page + 1, args: args);
      if (nextBatches.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextBatches]);
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
    final args = ref.read(adminBatchFilterProvider);
    try {
      final batches = await _fetchBatches(page: 1, args: args);
      state = AsyncData(batches);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final adminPaginatedBatchesProvider = AsyncNotifierProvider.autoDispose<
  AdminPaginatedBatchesNotifier,
  List<BatchModel>
>(AdminPaginatedBatchesNotifier.new);
