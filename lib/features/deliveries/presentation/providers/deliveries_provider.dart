import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/delivery_status.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/models/delivery_model.dart';
import '../../data/repositories/delivery_repository.dart';

final deliveriesProvider =
    AsyncNotifierProvider<DeliveriesNotifier, List<DeliveryModel>>(
      DeliveriesNotifier.new,
    );

class DeliveriesNotifier extends AsyncNotifier<List<DeliveryModel>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<DeliveryModel>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchDeliveries(page: 1);
  }

  Future<List<DeliveryModel>> _fetchDeliveries({required int page}) async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final results = await ref
        .watch(deliveryRepositoryProvider)
        .getDeliveriesPaginated(
          userId: user.id,
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
      final nextDeliveries = await _fetchDeliveries(page: _page + 1);
      if (nextDeliveries.isNotEmpty) {
        _page++;
        final currentData = state.value ?? [];
        state = AsyncData([...currentData, ...nextDeliveries]);
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
      final deliveries = await _fetchDeliveries(page: 1);
      state = AsyncData(deliveries);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? delayReason,
    String? locationName,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      await ref
          .read(deliveryRepositoryProvider)
          .updateDeliveryStatus(
            deliveryId: deliveryId,
            status: status,
            delayReason: delayReason,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
            notes: notes,
          );
      // Refresh the list
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
