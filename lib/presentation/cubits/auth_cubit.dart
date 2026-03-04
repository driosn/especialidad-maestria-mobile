import 'package:equilibra_mobile/data/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthService? authService})
    : _authService = authService ?? AuthService(),
      super(const AuthInitial());

  final AuthService _authService;

  Stream get authStateChanges => _authService.authStateChanges;

  void checkAuth() {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user.uid));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  }) async {
    emit(const AuthLoading());
    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
        lastName: lastName,
      );
      checkAuth();
    } catch (e, _) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      await _authService.signIn(email: email, password: password);
      checkAuth();
    } catch (e, _) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }
}
