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
  final int page;

  const BatchFilterArgs({
    this.searchQuery = '',
    this.stageFilter,
    this.statusFilter,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchFilterArgs &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          stageFilter == other.stageFilter &&
          statusFilter == other.statusFilter &&
          page == other.page;

  @override
  int get hashCode => searchQuery.hashCode ^ (stageFilter?.hashCode ?? 0) ^ (statusFilter?.hashCode ?? 0) ^ page.hashCode;
}

final paginatedBatchesProvider = FutureProvider.family.autoDispose<List<BatchModel>, BatchFilterArgs>((ref, args) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || user.collectionCentreId == null) return [];

  final repository = ref.watch(batchRepositoryProvider);
  return await repository.getBatchesPaginated(
    collectionCentreId: user.collectionCentreId!,
    searchQuery: args.searchQuery,
    stageFilter: args.stageFilter,
    statusFilter: args.statusFilter,
    page: args.page,
    pageSize: 50, // Simplified pagination for now
  );
});
