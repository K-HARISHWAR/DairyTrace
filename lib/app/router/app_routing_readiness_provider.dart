import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../core/enums/user_role.dart';
import '../../features/authentication/data/models/profile_model.dart';

class RoutingState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool hasProfile;
  final bool isActive;
  final UserRole? role;

  RoutingState({
    required this.isLoading,
    this.isAuthenticated = false,
    this.hasProfile = false,
    this.isActive = false,
    this.role,
  });
}

// We use a ChangeNotifier to easily hook into GoRouter's refreshListenable
class AppRoutingReadinessNotifier extends ChangeNotifier {
  final Ref ref;
  RoutingState _state = RoutingState(isLoading: true);

  AppRoutingReadinessNotifier(this.ref) {
    _init();
  }

  RoutingState get state => _state;

  void _init() {
    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _checkState();
    });
    
    // Also listen to Riverpod's auth/profile state if needed
    ref.listen(authStateProvider, (previous, next) {
      _checkState();
    });
    
    _checkState();
  }

  Future<void> _checkState() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      _state = RoutingState(isLoading: false, isAuthenticated: false);
      notifyListeners();
      return;
    }

    // Wait for the authProvider (which loads ProfileModel) to have data
    final profileAsyncValue = ref.read(authStateProvider);
    
    if (profileAsyncValue is AsyncLoading) {
      _state = RoutingState(isLoading: true, isAuthenticated: true);
      notifyListeners();
      return;
    }

    final profile = profileAsyncValue.value;
    
    _state = RoutingState(
      isLoading: false,
      isAuthenticated: true,
      hasProfile: profile != null,
      isActive: profile?.isActive ?? false,
      role: profile?.role,
    );
    notifyListeners();
  }
}

final appRoutingReadinessProvider = ChangeNotifierProvider<AppRoutingReadinessNotifier>((ref) {
  return AppRoutingReadinessNotifier(ref);
});
