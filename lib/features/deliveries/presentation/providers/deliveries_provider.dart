import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/delivery_status.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/models/delivery_model.dart';
import '../../data/repositories/delivery_repository.dart';

final deliveriesProvider = AsyncNotifierProvider<DeliveriesNotifier, List<DeliveryModel>>(DeliveriesNotifier.new);

class DeliveriesNotifier extends AsyncNotifier<List<DeliveryModel>> {
  @override
  FutureOr<List<DeliveryModel>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.watch(deliveryRepositoryProvider).getDeliveriesForUser(user.id);
  }

  Future<void> fetchDeliveries() async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        state = const AsyncData([]);
        return;
      }
      final deliveries = await ref.read(deliveryRepositoryProvider).getDeliveriesForUser(user.id);
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
      await ref.read(deliveryRepositoryProvider).updateDeliveryStatus(
        deliveryId: deliveryId,
        status: status,
        delayReason: delayReason,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      // Refresh the list
      await fetchDeliveries();
    } catch (e) {
      rethrow;
    }
  }
}
