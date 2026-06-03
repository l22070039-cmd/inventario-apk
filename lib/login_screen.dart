import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'main.dart';

// ─────────────────────────────────────────────────────────────
// PANTALLA PRINCIPAL DE AUTH (Login / Registro / Recuperar)
// ─────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthView { login, register, recover, resetCode }

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  _AuthView _view = _AuthView.login;

  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _switchView(_AuthView v) {
    _animCtrl.reverse().then((_) {
      setState(() => _view = v);
      _animCtrl.forward();
    });
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          _Background(),
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: switch (_view) {
                  _AuthView.login => _LoginForm(
                      onSuccess: _goHome,
                      onRegister: () => _switchView(_AuthView.register),
                      onRecover: () => _switchView(_AuthView.recover),
                    ),
                  _AuthView.register => _RegisterForm(
                      onSuccess: _goHome,
                      onBack: () => _switchView(_AuthView.login),
                    ),
                  _AuthView.recover => _RecoverForm(
                      onBack: () => _switchView(_AuthView.login),
                      onCodeSent: () => _switchView(_AuthView.resetCode),
                    ),
                  _AuthView.resetCode => _ResetCodeForm(
                      onSuccess: () => _switchView(_AuthView.login),
                      onBack: () => _switchView(_AuthView.recover),
                    ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FONDO DECORATIVO
// ─────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: -120,
        right: -80,
        child: _GlowCircle(size: 380, opacity: 0.07),
      ),
      Positioned(
        bottom: -100,
        left: -60,
        child: _GlowCircle(size: 300, opacity: 0.04),
      ),
    ]);
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            const Color(0xFF4FC3F7).withOpacity(opacity),
            Colors.transparent,
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// COMPONENTES COMPARTIDOS
// ─────────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 28, height: 1.5, color: const Color(0xFF4FC3F7)),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4FC3F7),
            fontSize: 11,
            letterSpacing: 3,
            fontFamily: 'Roboto',
          ),
        ),
      ]);
}

class _HeroTitle extends StatelessWidget {
  final String line1;
  final String line2;
  const _HeroTitle({required this.line1, required this.line2});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            line2,
            style: const TextStyle(
              color: Color(0xFF4FC3F7),
              fontSize: 42,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              height: 1.1,
            ),
          ),
        ],
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF90A4AE),
          fontSize: 13,
          letterSpacing: 0.5,
          fontFamily: 'Roboto',
        ),
      );
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? errorText;

  const _DarkField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111118),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: errorText != null
                    ? const Color(0xFFEF5350).withOpacity(0.6)
                    : const Color(0xFF1E2A35),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Roboto',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF37474F)),
                prefixIcon: Icon(icon, color: const Color(0xFF546E7A), size: 20),
                suffixIcon: suffix,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 5),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
        ],
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: const Color(0xFF0A0A0F),
            disabledBackgroundColor: const Color(0xFF4FC3F7).withOpacity(0.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF0A0A0F),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
        ),
      );
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF263238), width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          ),
        ),
      );
}

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _LinkButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4FC3F7),
            fontSize: 14,
            fontFamily: 'Roboto',
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF4FC3F7),
          ),
        ),
      );
}

void _showError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: const Color(0xFF1A1A2E),
    content: Text(msg, style: const TextStyle(color: Color(0xFFEF5350))),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ));
}

void _showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: const Color(0xFF1A1A2E),
    content: Text(msg, style: const TextStyle(color: Color(0xFF4FC3F7))),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ));
}

// ─────────────────────────────────────────────────────────────
// FORM: LOGIN
// ─────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onRegister;
  final VoidCallback onRecover;
  const _LoginForm({
    required this.onSuccess,
    required this.onRegister,
    required this.onRecover,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _emailErr;
  String? _passErr;

  bool _validate() {
    setState(() {
      _emailErr = _email.text.trim().isEmpty
          ? 'Ingresa tu correo'
          : !_email.text.contains('@')
              ? 'Correo inválido'
              : null;
      _passErr = _pass.text.isEmpty ? 'Ingresa tu contraseña' : null;
    });
    return _emailErr == null && _passErr == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.instance.login(
      email: _email.text.trim(),
      password: _pass.text,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    if (result.ok) {
      widget.onSuccess();
    } else {
      _showError(context, result.error!);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('Sistema de inventario'),
          const SizedBox(height: 20),
          const _HeroTitle(line1: 'Bienvenido', line2: 'de vuelta'),
          const SizedBox(height: 10),
          const Text(
            'Inicia sesión para gestionar tu inventario.',
            style: TextStyle(
                color: Color(0xFF78909C), fontSize: 15, fontFamily: 'Roboto'),
          ),
          const SizedBox(height: 44),

          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _email,
            hint: 'tu@correo.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailErr,
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Contraseña'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _pass,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: _obscure,
            errorText: _passErr,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF546E7A),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: _LinkButton(
              label: '¿Olvidaste tu contraseña?',
              onPressed: widget.onRecover,
            ),
          ),
          const SizedBox(height: 36),

          _PrimaryButton(
            label: 'Iniciar Sesión',
            onPressed: _login,
            loading: _loading,
          ),
          const SizedBox(height: 14),
          _SecondaryButton(label: 'Crear cuenta', onPressed: widget.onRegister),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// FORM: REGISTRO
// ─────────────────────────────────────────────────────────────

class _RegisterForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const _RegisterForm({required this.onSuccess, required this.onBack});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _nombreErr, _emailErr, _passErr, _confirmErr;

  bool _validate() {
    setState(() {
      _nombreErr =
          _nombre.text.trim().isEmpty ? 'Ingresa tu nombre' : null;
      _emailErr = _email.text.trim().isEmpty
          ? 'Ingresa tu correo'
          : !_email.text.contains('@')
              ? 'Correo inválido'
              : null;
      _passErr = _pass.text.length < 6
          ? 'Mínimo 6 caracteres'
          : null;
      _confirmErr = _confirm.text != _pass.text
          ? 'Las contraseñas no coinciden'
          : null;
    });
    return _nombreErr == null &&
        _emailErr == null &&
        _passErr == null &&
        _confirmErr == null;
  }

  Future<void> _register() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.instance.registrar(
      nombre: _nombre.text.trim(),
      email: _email.text.trim(),
      password: _pass.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result.ok) {
      widget.onSuccess();
    } else {
      _showError(context, result.error!);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('Crear cuenta'),
          const SizedBox(height: 20),
          const _HeroTitle(line1: 'Únete', line2: 'ahora'),
          const SizedBox(height: 10),
          const Text(
            'Crea tu cuenta para empezar a gestionar tu inventario.',
            style: TextStyle(
                color: Color(0xFF78909C), fontSize: 15, fontFamily: 'Roboto'),
          ),
          const SizedBox(height: 44),

          const _FieldLabel('Nombre completo'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _nombre,
            hint: 'Tu nombre',
            icon: Icons.person_outline,
            errorText: _nombreErr,
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _email,
            hint: 'tu@correo.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailErr,
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Contraseña'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _pass,
            hint: 'Mínimo 6 caracteres',
            icon: Icons.lock_outline,
            obscure: _obscure1,
            errorText: _passErr,
            suffix: IconButton(
              icon: Icon(
                _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF546E7A),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Confirmar contraseña'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _confirm,
            hint: 'Repite tu contraseña',
            icon: Icons.lock_outline,
            obscure: _obscure2,
            errorText: _confirmErr,
            suffix: IconButton(
              icon: Icon(
                _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF546E7A),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),
          const SizedBox(height: 36),

          _PrimaryButton(
            label: 'Registrarme',
            onPressed: _register,
            loading: _loading,
          ),
          const SizedBox(height: 14),
          _SecondaryButton(label: 'Ya tengo cuenta', onPressed: widget.onBack),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// FORM: RECUPERAR CONTRASEÑA
// ─────────────────────────────────────────────────────────────

class _RecoverForm extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onCodeSent;
  const _RecoverForm({required this.onBack, required this.onCodeSent});

  @override
  State<_RecoverForm> createState() => _RecoverFormState();
}

class _RecoverFormState extends State<_RecoverForm> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _emailErr;

  Future<void> _send() async {
    setState(() {
      _emailErr = _email.text.trim().isEmpty
          ? 'Ingresa tu correo'
          : !_email.text.contains('@')
              ? 'Correo inválido'
              : null;
    });
    if (_emailErr != null) return;

    setState(() => _loading = true);
    final result =
        await AuthService.instance.enviarRecuperacion(_email.text.trim());
    setState(() => _loading = false);

    if (!mounted) return;
    if (result.error != null) {
      _showError(context, result.error!);
    } else {
      _showSuccess(context, result.mensaje!);
      widget.onCodeSent();
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('Recuperar acceso'),
          const SizedBox(height: 20),
          const _HeroTitle(line1: 'Olvidaste', line2: 'tu contraseña'),
          const SizedBox(height: 10),
          const Text(
            'Ingresa tu correo y te enviaremos un código para restablecer tu contraseña.',
            style: TextStyle(
                color: Color(0xFF78909C), fontSize: 15, fontFamily: 'Roboto'),
          ),
          const SizedBox(height: 44),

          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _email,
            hint: 'tu@correo.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailErr,
          ),
          const SizedBox(height: 36),

          _PrimaryButton(
            label: 'Enviar código',
            onPressed: _send,
            loading: _loading,
          ),
          const SizedBox(height: 14),
          _SecondaryButton(label: 'Volver al login', onPressed: widget.onBack),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// FORM: INGRESAR CÓDIGO + NUEVA CONTRASEÑA
// ─────────────────────────────────────────────────────────────

class _ResetCodeForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onBack;
  const _ResetCodeForm({required this.onSuccess, required this.onBack});

  @override
  State<_ResetCodeForm> createState() => _ResetCodeFormState();
}

class _ResetCodeFormState extends State<_ResetCodeForm> {
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _emailErr, _tokenErr, _passErr, _confirmErr;

  bool _validate() {
    setState(() {
      _emailErr = !_email.text.contains('@') ? 'Correo inválido' : null;
      _tokenErr =
          _token.text.length != 6 ? 'El código debe tener 6 dígitos' : null;
      _passErr = _pass.text.length < 6 ? 'Mínimo 6 caracteres' : null;
      _confirmErr =
          _confirm.text != _pass.text ? 'Las contraseñas no coinciden' : null;
    });
    return _emailErr == null &&
        _tokenErr == null &&
        _passErr == null &&
        _confirmErr == null;
  }

  Future<void> _reset() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.instance.cambiarPasswordConToken(
      email: _email.text.trim(),
      token: _token.text.trim(),
      nuevaPassword: _pass.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result.ok) {
      _showSuccess(context, '¡Contraseña actualizada! Ya puedes iniciar sesión.');
      widget.onSuccess();
    } else {
      _showError(context, result.error!);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('Nueva contraseña'),
          const SizedBox(height: 20),
          const _HeroTitle(line1: 'Cambia', line2: 'tu acceso'),
          const SizedBox(height: 10),
          const Text(
            'Ingresa el código que recibiste y elige una nueva contraseña.',
            style: TextStyle(
                color: Color(0xFF78909C), fontSize: 15, fontFamily: 'Roboto'),
          ),
          const SizedBox(height: 44),

          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _email,
            hint: 'tu@correo.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailErr,
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Código de verificación'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _token,
            hint: '000000',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            errorText: _tokenErr,
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Nueva contraseña'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _pass,
            hint: 'Mínimo 6 caracteres',
            icon: Icons.lock_outline,
            obscure: _obscure1,
            errorText: _passErr,
            suffix: IconButton(
              icon: Icon(
                _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF546E7A),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          const SizedBox(height: 20),

          const _FieldLabel('Confirmar contraseña'),
          const SizedBox(height: 8),
          _DarkField(
            controller: _confirm,
            hint: 'Repite tu contraseña',
            icon: Icons.lock_outline,
            obscure: _obscure2,
            errorText: _confirmErr,
            suffix: IconButton(
              icon: Icon(
                _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF546E7A),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),
          const SizedBox(height: 36),

          _PrimaryButton(
            label: 'Cambiar contraseña',
            onPressed: _reset,
            loading: _loading,
          ),
          const SizedBox(height: 14),
          _SecondaryButton(label: 'Volver', onPressed: widget.onBack),
        ],
      );
}