import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _authService = AuthService();

  String _rolSeleccionado = 'alumno';
  bool _cargando = false;
  String? _error;

  Future<void> _registrar() async {
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _tokenController.text.trim().isEmpty) {
      setState(() => _error = 'Completá todos los campos.');
      return;
    }

    if (_passwordController.text != _confirmarPasswordController.text) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final error = await _authService.registrarConToken(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nombre: _nombreController.text.trim(),
      token: _tokenController.text.trim(),
      rolSeleccionado: _rolSeleccionado,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;
        _cargando = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // ---- TÍTULO ----
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completá tus datos para registrarte',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 36),

                // ---- NOMBRE ----
                _buildCampo(
                  controller: _nombreController,
                  hint: 'NOMBRE COMPLETO',
                  icono: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                // ---- EMAIL ----
                _buildCampo(
                  controller: _emailController,
                  hint: 'EMAIL',
                  icono: Icons.email_outlined,
                  teclado: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // ---- CONTRASEÑA ----
                _buildCampo(
                  controller: _passwordController,
                  hint: 'CONTRASEÑA',
                  icono: Icons.lock_outline,
                  esPassword: true,
                ),
                const SizedBox(height: 14),

                // ---- CONFIRMAR CONTRASEÑA ----
                _buildCampo(
                  controller: _confirmarPasswordController,
                  hint: 'CONFIRMAR CONTRASEÑA',
                  icono: Icons.lock_outline,
                  esPassword: true,
                ),
                const SizedBox(height: 14),

                // ---- SELECTOR DE ROL ----
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _rolSeleccionado,
                      isExpanded: true,
                      dropdownColor: const Color.fromARGB(255, 15, 126, 134),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white60),
                      items: const [
                        DropdownMenuItem(
                          value: 'alumno',
                          child: Text(
                            'Alumno',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'profesor',
                          child: Text(
                            'Profesor',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'familia',
                          child: Text(
                            'Familia',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      DropdownMenuItem(
                          value: 'preceptor',
                          child: Text(
                            'Preceptor',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (valor) {
                        setState(() => _rolSeleccionado = valor!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ---- TOKEN ----
                _buildCampo(
                  controller: _tokenController,
                  hint: 'TOKEN',
                  icono: Icons.vpn_key_outlined,
                ),
                const SizedBox(height: 20),

                // ---- MENSAJE DE ERROR ----
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ---- BOTÓN REGISTRARSE ----
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
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
                            'REGISTRARSE',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---- LINK VOLVER AL LOGIN ----
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '¿Ya tenés cuenta? Iniciá sesión',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 30),
              ],
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
}