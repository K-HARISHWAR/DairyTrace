import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/farm_model.dart';

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepository(ref.watch(supabaseServiceProvider).client);
});

class FarmRepository {
  final SupabaseClient _client;

  FarmRepository(this._client);

  Future<List<FarmModel>> getFarms() async {
    final data = await _client
        .from(DatabaseTables.farms)
        .select()
        .order('created_at', ascending: false);
    
    return (data as List).map((e) => FarmModel.fromJson(e)).toList();
  }

  Future<FarmModel> registerFarm({
    required String farmerName,
    String? phone,
    String? address,
    double? lat,
    double? lng,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    final data = await _client.from(DatabaseTables.farms).insert({
      'farmer_name': farmerName,
      'phone': phone,
      'address': address,
      'location_lat': lat,
      'location_lng': lng,
      'registered_by': userId,
    }).select().single();

    return FarmModel.fromJson(data);
  }
}
