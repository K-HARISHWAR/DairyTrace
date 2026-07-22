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

  Future<List<FarmModel>> getFarms({String? collectionCentreId}) async {
    var query = _client.from(DatabaseTables.farms).select();
    
    if (collectionCentreId != null) {
      query = query.eq('collection_centre_id', collectionCentreId);
    }
    
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => FarmModel.fromJson(e)).toList();
  }

  Future<List<FarmModel>> getFarmsPaginated({
    required String collectionCentreId,
    String? searchQuery,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    var query = _client.from(DatabaseTables.farms).select().eq('collection_centre_id', collectionCentreId);
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('farm_name.ilike.%$searchQuery%,farm_code.ilike.%$searchQuery%,owner_name.ilike.%$searchQuery%,village.ilike.%$searchQuery%');
    }

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final data = await query.range(from, to).order('created_at', ascending: false);
    return (data as List).map((e) => FarmModel.fromJson(e)).toList();
  }

  Future<FarmModel> getFarmById(String id) async {
    final data = await _client.from(DatabaseTables.farms).select().eq('id', id).single();
    return FarmModel.fromJson(data);
  }

  Future<FarmModel> registerFarm({
    required String farmCode,
    required String farmName,
    required String ownerName,
    String? phone,
    required String village,
    String? district,
    String? state,
    String? address,
    double? latitude,
    double? longitude,
    required String collectionCentreId,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    final data = await _client.from(DatabaseTables.farms).insert({
      'farm_code': farmCode,
      'farm_name': farmName,
      'owner_name': ownerName,
      'phone': phone,
      'village': village,
      'district': district,
      'state': state,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'collection_centre_id': collectionCentreId,
      'created_by': userId,
    }).select().single();

    return FarmModel.fromJson(data);
  }
}
