import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'admin_screen.dart';
import 'preceptor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _cargando = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 126, 134),
              Color.fromARGB(255, 15, 126, 134),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ---- LOGO ----
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(0, 255, 255, 255),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---- NOMBRE APP ----
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'EDU',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2F6F),
                            letterSpacing: 2,
                          ),
                        ),
                        TextSpan(
                          text: 'CONTROL',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE87722),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Conectando',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A2F6F),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: ' escuela y hogar',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFE87722),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---- CAMPO EMAIL ----
                  _buildCampo(
                    controller: _emailController,
                    hint: 'EMAIL',
                    icono: Icons.email_outlined,
                    teclado: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // ---- CAMPO CONTRASEÑA ----
                  _buildCampo(
                    controller: _passwordController,
                    hint: 'CONTRASEÑA',
                    icono: Icons.lock_outline,
                    esPassword: true,
                  ),
                  const SizedBox(height: 20),

                  // ---- MENSAJE DE ERROR ----
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // ---- BOTÓN INICIAR SESIÓN ----
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87722),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'INICIAR SESIÓN',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- LINK REGISTRO ----
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿No tenés cuenta? Registrate con un token',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    bool esPassword = false,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white60,
          letterSpacing: 1.2,
          fontSize: 13,
        ),
        prefixIcon: Icon(icono, color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE87722)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

Future<void> _iniciarSesion() async {
  if (_emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty) {
    setState(() {
      _error = 'Completá todos los campos.';
    });
    return;
  }

  setState(() {
    _cargando = true;
    _error = null;
  });

  final error = await _authService.iniciarSesion(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );

  if (!mounted) return;

  if (error != null) {
    setState(() {
      _error = error;
      _cargando = false;
    });
  } else {
    final rol = await _authService.obtenerRol();
    debugPrint('ROL DETECTADO: $rol');
    setState(() => _cargando = false);
    _navegarSegunRol(rol);
  }
}

void _navegarSegunRol(String? rol) {
  Widget pantalla;
  switch (rol) {
    case 'admin':
      pantalla = const AdminScreen();
      break;
    case 'preceptor':
      pantalla = const PreceptorScreen();
      break;
    default:
      pantalla = const LoginScreen();
      break;
  }
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => pantalla),
  );
}
}