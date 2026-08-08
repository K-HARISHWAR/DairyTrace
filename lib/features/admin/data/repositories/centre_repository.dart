import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/centre_model.dart';

final centreRepositoryProvider = Provider<CentreRepository>((ref) {
  return CentreRepository(ref.watch(supabaseServiceProvider).client);
});

class CentreRepository {
  final SupabaseClient _client;

  CentreRepository(this._client);

  Future<List<CentreModel>> getCentresPaginated({
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    var query = _client.from(DatabaseTables.collectionCentres).select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%$searchQuery%,centre_code.ilike.%$searchQuery%,village.ilike.%$searchQuery%',
      );
    }

    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final data = await query
        .range(from, to)
        .order('created_at', ascending: false);
    return (data as List).map((e) => CentreModel.fromJson(e)).toList();
  }
}
