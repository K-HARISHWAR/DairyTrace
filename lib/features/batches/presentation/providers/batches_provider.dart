import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/batch_model.dart';
import '../../data/repositories/batch_repository.dart';

class BatchesNotifier extends AsyncNotifier<List<BatchModel>> {
  @override
  Future<List<BatchModel>> build() async {
    return ref.watch(batchRepositoryProvider).getBatches();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final batches = await ref.read(batchRepositoryProvider).getBatches();
      state = AsyncData(batches);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addBatch(BatchModel batch) async {
    if (state.hasValue) {
      state = AsyncData([batch, ...state.value!]);
    } else {
      await refresh();
    }
  }
}

final batchesProvider =
    AsyncNotifierProvider<BatchesNotifier, List<BatchModel>>(
      BatchesNotifier.new,
    );

final batchByIdProvider = FutureProvider.family<BatchModel, String>((ref, id) async {
  return ref.watch(batchRepositoryProvider).getBatchById(id);
});
