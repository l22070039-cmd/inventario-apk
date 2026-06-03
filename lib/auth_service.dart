import 'database_helper.dart';

/// Usuario autenticado en sesión actual.
class AppUser {
  final String id;
  final String nombre;
  final String email;

  const AppUser({
    required this.id,
    required this.nombre,
    required this.email,
  });
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _db = DatabaseHelper();
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── REGISTRO ──────────────────────────────────────────────

  Future<AuthResult> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final localUser = await _db.registrarUsuario(
      nombre: nombre,
      email: email,
      password: password,
    );

    if (localUser == null) {
      return AuthResult.error('Este correo ya está registrado.');
    }

    _currentUser = AppUser(
      id: localUser['id'].toString(),
      nombre: localUser['nombre'],
      email: localUser['email'],
    );
    return AuthResult.success(_currentUser!);
  }

  // ── LOGIN ─────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final localUser = await _db.loginUsuario(
      email: email,
      password: password,
    );

    if (localUser == null) {
      return AuthResult.error('Correo o contraseña incorrectos.');
    }

    _currentUser = AppUser(
      id: localUser['id'].toString(),
      nombre: localUser['nombre'],
      email: localUser['email'],
    );
    return AuthResult.success(_currentUser!);
  }

  // ── RECUPERAR CONTRASEÑA ──────────────────────────────────

  Future<RecoveryResult> enviarRecuperacion(String email) async {
    final token = await _db.generarTokenRecuperacion(email);

    if (token == null) {
      return RecoveryResult(
        mensaje: null,
        error: 'No encontramos una cuenta con ese correo.',
      );
    }

    return RecoveryResult(
      mensaje: 'Tu código de recuperación es: $token\n(válido por 15 minutos)',
      token: token,
    );
  }

  Future<AuthResult> cambiarPasswordConToken({
    required String email,
    required String token,
    required String nuevaPassword,
  }) async {
    final ok = await _db.resetPassword(
      email: email,
      token: token,
      nuevaPassword: nuevaPassword,
    );

    if (!ok) return AuthResult.error('Código inválido o expirado.');
    return AuthResult.success(null);
  }

  // ── LOGOUT ────────────────────────────────────────────────

  Future<void> logout() async {
    _currentUser = null;
  }
}

// ── Tipos de resultado ─────────────────────────────────────

class AuthResult {
  final bool ok;
  final AppUser? user;
  final String? error;

  const AuthResult._({required this.ok, this.user, this.error});

  factory AuthResult.success(AppUser? user) =>
      AuthResult._(ok: true, user: user);

  factory AuthResult.error(String message) =>
      AuthResult._(ok: false, error: message);
}

class RecoveryResult {
  final String? mensaje;
  final String? error;
  final String? token;

  const RecoveryResult({
    required this.mensaje,
    this.error,
    this.token,
  });
}