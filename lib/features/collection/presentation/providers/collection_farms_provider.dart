import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../farms/data/models/farm_model.dart';
import '../../../farms/data/repositories/farm_repository.dart';

class FarmFilterArgs {
  final String searchQuery;
  final bool? isActive;
  final int page;

  const FarmFilterArgs({
    this.searchQuery = '',
    this.isActive,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmFilterArgs &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          isActive == other.isActive &&
          page == other.page;

  @override
  int get hashCode => searchQuery.hashCode ^ (isActive?.hashCode ?? 0) ^ page.hashCode;
}

final paginatedFarmsProvider = FutureProvider.family.autoDispose<List<FarmModel>, FarmFilterArgs>((ref, args) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || user.collectionCentreId == null) return [];

  final repository = ref.watch(farmRepositoryProvider);
  return await repository.getFarmsPaginated(
    collectionCentreId: user.collectionCentreId!,
    searchQuery: args.searchQuery,
    isActive: args.isActive,
    page: args.page,
    pageSize: 50, // Keep simple for now
  );
});
