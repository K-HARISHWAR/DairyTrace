import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../batches/data/models/batch_model.dart';
import '../../../batches/data/repositories/batch_repository.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../../core/enums/batch_status.dart';

class BatchFilterArgs {
  final String searchQuery;
  final BatchStage? stageFilter;
  final BatchStatus? statusFilter;

  const BatchFilterArgs({
    this.searchQuery = '',
    this.stageFilter,
    this.statusFilter,
  });

  BatchFilterArgs copyWith({
    String? searchQuery,
    BatchStage? stageFilter,
    BatchStatus? statusFilter,
  }) {
    return BatchFilterArgs(
      searchQuery: searchQuery ?? this.searchQuery,
      stageFilter: stageFilter ?? this.stageFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchFilterArgs &&
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

// Notifier for preserving filters
class BatchFilterNotifier extends Notifier<BatchFilterArgs> {
  @override
  BatchFilterArgs build() => const BatchFilterArgs();

  void updateSearchQuery(String query) {
    state = BatchFilterArgs(
      searchQuery: query,
      stageFilter: state.stageFilter,
      statusFilter: state.statusFilter,
    );
  }

  void updateStageFilter(BatchStage? stage) {
    state = BatchFilterArgs(
      searchQuery: state.searchQuery,
      stageFilter: stage,
      statusFilter: state.statusFilter,
    );
  }

  void updateStatusFilter(BatchStatus? status) {
    state = BatchFilterArgs(
      searchQuery: state.searchQuery,
      stageFilter: state.stageFilter,
      statusFilter: status,
    );
  }
}

final batchFilterProvider =
    NotifierProvider<BatchFilterNotifier, BatchFilterArgs>(
      BatchFilterNotifier.new,
    );

// AsyncNotifier for fetching data based on filters
class PaginatedBatchesNotifier
    extends AsyncNotifier<List<BatchModel>> {
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
    final args = ref.watch(batchFilterProvider);
    return _fetchBatches(page: 1, args: args);
  }

  Future<List<BatchModel>> _fetchBatches({required int page, required BatchFilterArgs args}) async {
    final user = ref.watch(authStateProvider).value;

    if (user == null || user.collectionCentreId == null) return [];

    final repository = ref.watch(batchRepositoryProvider);
    final results = await repository.getBatchesPaginated(
      collectionCentreId: user.collectionCentreId!,
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
    final args = ref.read(batchFilterProvider);

    try {
      final nextBatches = await _fetchBatches(page: _page + 1, args: args);
      if (nextBatches.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextBatches]);
      }
    } catch (e, st) {
      // Don't overwrite the state with an error if we already have data, just log or handle
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasMore = true;
    final args = ref.read(batchFilterProvider);
    try {
      final batches = await _fetchBatches(page: 1, args: args);
      state = AsyncData(batches);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final paginatedBatchesProvider =
    AsyncNotifierProvider.autoDispose<
      PaginatedBatchesNotifier,
      List<BatchModel>
    >(PaginatedBatchesNotifier.new);
