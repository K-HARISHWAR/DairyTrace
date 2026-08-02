import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  FutureOr<ProfileModel?> build() async {
    return _fetchUser();
  }

  Future<ProfileModel?> _fetchUser() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final user = await _fetchUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).signIn(email, password);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, ProfileModel?>(AuthNotifier.new);
