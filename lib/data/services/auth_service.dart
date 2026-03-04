import 'package:firebase_auth/firebase_auth.dart';
import 'package:equilibra_mobile/data/services/user_service.dart';

/// Servicio de autenticación. Crea el documento en la colección `users`
/// con schema: name, lastName, email, createdAt.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userService = userService ?? UserService();

  final FirebaseAuth _auth;
  final UserService _userService;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    await _userService.createUser(
      uid: user.uid,
      name: name,
      lastName: lastName,
      email: email,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
