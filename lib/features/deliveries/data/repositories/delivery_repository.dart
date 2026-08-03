import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/delivery_model.dart';
import '../../../../core/enums/delivery_status.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(supabaseServiceProvider).client);
});

class DeliveryRepository {
  final SupabaseClient _client;

  DeliveryRepository(this._client);

  Future<List<DeliveryModel>> getDeliveriesForUser(String userId) async {
    final data = await _client
        .from(DatabaseTables.deliveries)
        .select(
          '*, batches(batch_code, quantity_litres, collection_centres(name), farms(farm_name))',
        )
        .eq('assigned_to', userId)
        .order('assigned_at', ascending: false);

    return (data as List).map((e) => DeliveryModel.fromJson(e)).toList();
  }

  Future<List<DeliveryModel>> getDeliveriesPaginated({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final data = await _client
        .from(DatabaseTables.deliveries)
        .select(
          '*, batches(batch_code, quantity_litres, collection_centres(name), farms(farm_name))',
        )
        .eq('assigned_to', userId)
        .order('assigned_at', ascending: false)
        .range(from, to);

    return (data as List).map((e) => DeliveryModel.fromJson(e)).toList();
  }

  Future<DeliveryModel> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? delayReason,
    String? locationName,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final data = await _client.rpc(
      'update_delivery_status',
      params: {
        'p_delivery_id': deliveryId,
        'p_status': status.value,
        'p_delay_reason': delayReason,
        'p_location_name': locationName,
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_notes': notes,
      },
    );
    return DeliveryModel.fromJson(data);
  }
}
