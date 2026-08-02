import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';

class ActiveFarmsDropdownNotifier extends AutoDisposeAsyncNotifier<List<FarmModel>> {
  @override
  FutureOr<List<FarmModel>> build() async {
    return _fetchActiveFarms();
  }

  Future<List<FarmModel>> _fetchActiveFarms() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null || user.collectionCentreId == null) return [];

    final repository = ref.watch(farmRepositoryProvider);
    return await repository.getFarmsPaginated(
      collectionCentreId: user.collectionCentreId!,
      isActive: true,
      page: 1,
      pageSize: 100, // Fetch up to 100 active farms for the dropdown
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final farms = await _fetchActiveFarms();
      state = AsyncData(farms);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final activeFarmsDropdownProvider = AutoDisposeAsyncNotifierProvider<ActiveFarmsDropdownNotifier, List<FarmModel>>(ActiveFarmsDropdownNotifier.new);
