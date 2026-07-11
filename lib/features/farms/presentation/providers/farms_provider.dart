import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/farm_model.dart';
import '../../data/repositories/farm_repository.dart';

final farmsProvider = AsyncNotifierProvider<FarmsNotifier, List<FarmModel>>(FarmsNotifier.new);

class FarmsNotifier extends AsyncNotifier<List<FarmModel>> {
  @override
  FutureOr<List<FarmModel>> build() async {
    return ref.watch(farmRepositoryProvider).getFarms();
  }

  Future<void> fetchFarms() async {
    state = const AsyncLoading();
    try {
      final farms = await ref.read(farmRepositoryProvider).getFarms();
      state = AsyncData(farms);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addFarm(FarmModel farm) async {
    if (state.hasValue) {
      state = AsyncData([farm, ...state.value!]);
    } else {
      await fetchFarms();
    }
  }
}
