import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../core/models/user.dart';
import '../core/services/auth_service.dart';
import 'providers.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getCachedUser();
      if (user != null) {
        state = state.copyWith(user: user);
        // Refresh user data from server
        await getCurrentUser();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email: email, password: password);
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String name, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        email: email,
        name: name,
        password: password,
      );
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Ignore errors when refreshing user
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? currentPassword,
    String? newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.updateProfile(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
