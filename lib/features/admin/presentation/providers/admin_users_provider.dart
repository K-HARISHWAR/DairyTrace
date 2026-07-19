import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/data/models/profile_model.dart';
import '../../data/repositories/admin_repository.dart';

final adminUsersProvider = FutureProvider<List<ProfileModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAllUsers();
});
