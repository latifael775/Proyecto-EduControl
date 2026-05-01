import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/token_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _tokenService = TokenService();
  final _authService = AuthService();
  bool _cargando = false;

  void _mostrarToken(String token, String tipo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Token de $tipo generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Compartí este token con el usuario:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    token,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copiado')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generarToken(String tipo) async {
    setState(() => _cargando = true);
    String token;
    switch (tipo) {
      case 'profesor':
        token = await _tokenService.crearTokenProfesor();
        break;
      case 'preceptor':
        token = await _tokenService.crearTokenPreceptor();
        break;
      default:
        token = await _tokenService.crearTokenProfesor();
    }
    setState(() => _cargando = false);
    if (mounted) _mostrarToken(token, tipo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        backgroundColor: const Color(0xFF1A2F6F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.cerrarSesion();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Generador de tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2F6F),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Generá tokens para que los usuarios puedan registrarse.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ---- TOKEN PROFESOR ----
            _buildTarjetaToken(
              titulo: 'Profesor',
              descripcion: 'El profesor podrá ver cursos, tomar asistencia y cargar notas.',
              icono: Icons.person_outline,
              color: Colors.indigo,
              onTap: () => _generarToken('profesor'),
            ),
            const SizedBox(height: 16),

            // ---- TOKEN PRECEPTOR ----
            _buildTarjetaToken(
              titulo: 'Preceptor',
              descripcion: 'El preceptor podrá crear cursos, grupos y gestionar alumnos.',
              icono: Icons.manage_accounts_outlined,
              color: Colors.teal,
              onTap: () => _generarToken('preceptor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaToken({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            descripcion,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : onTap,
              icon: const Icon(Icons.add),
              label: Text('Generar token de $titulo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}