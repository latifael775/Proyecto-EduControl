import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'curso_detalle_screen.dart';

class PreceptorScreen extends StatefulWidget {
  const PreceptorScreen({super.key});

  @override
  State<PreceptorScreen> createState() => _PreceptorScreenState();
}

class _PreceptorScreenState extends State<PreceptorScreen> {
  final _authService = AuthService();
  final _db = FirebaseFirestore.instance;
  final _nombreCursoController = TextEditingController();

  // Obtiene el uid del preceptor actual
  String get _uid => _authService.usuarioActual!.uid;

  // Muestra el dialog para crear un curso nuevo
  void _mostrarDialogCrearCurso() {
  _nombreCursoController.clear();
  String? tecnicaturaSeleccionada;
  bool mostrarTecnicatura = false;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Crear curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCursoController,
              decoration: const InputDecoration(
                labelText: 'Nombre del curso',
                hintText: 'Ej: 5to 1ra',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (valor) {
                // Detecta si el curso es de 4to a 7mo
                final v = valor.toLowerCase().trim();
                final esTecnica = v.startsWith('4') ||
                    v.startsWith('5') ||
                    v.startsWith('6') ||
                    v.startsWith('7') ||
                    v.startsWith('4to') ||
                    v.startsWith('5to') ||
                    v.startsWith('6to') ||
                    v.startsWith('7mo');
                setStateDialog(() {
                  mostrarTecnicatura = esTecnica;
                  if (!esTecnica) tecnicaturaSeleccionada = null;
                });
              },
            ),

            // Aparece solo si el curso es de 4to a 7mo
            if (mostrarTecnicatura) ...[
              const SizedBox(height: 16),
              const Text(
                'Tecnicatura:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildOpcionTecnicatura(
                'Informática Personal y Profesional',
                Icons.computer,
                tecnicaturaSeleccionada,
                (val) => setStateDialog(() => tecnicaturaSeleccionada = val),
              ),
              const SizedBox(height: 8),
              _buildOpcionTecnicatura(
                'Tecnología de los Alimentos',
                Icons.restaurant,
                tecnicaturaSeleccionada,
                (val) => setStateDialog(() => tecnicaturaSeleccionada = val),
              ),
              const SizedBox(height: 8),
              _buildOpcionTecnicatura(
                'Servicios Turísticos',
                Icons.travel_explore,
                tecnicaturaSeleccionada,
                (val) => setStateDialog(() => tecnicaturaSeleccionada = val),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Si es tecnica y no eligió tecnicatura, no dejamos continuar
              if (mostrarTecnicatura && tecnicaturaSeleccionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seleccioná una tecnicatura'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _crearCurso(tecnicaturaSeleccionada);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A2F6F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    ),
  );
}

// Widget para cada opción de tecnicatura
Widget _buildOpcionTecnicatura(
  String nombre,
  IconData icono,
  String? seleccionada,
  Function(String) onTap,
) {
  final seleccionado = seleccionada == nombre;
  return GestureDetector(
    onTap: () => onTap(nombre),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: seleccionado ? Colors.teal : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: seleccionado ? Colors.teal : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(icono,
              color: seleccionado ? Colors.white : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.black,
                fontWeight: seleccionado
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (seleccionado)
            const Icon(Icons.check, color: Colors.white, size: 18),
        ],
      ),
    ),
  );
}

  // Crea el curso en Firestore
  Future<void> _crearCurso(String? tecnicatura) async {
  final nombre = _nombreCursoController.text.trim();
  if (nombre.isEmpty) return;

  Map<String, dynamic> datosCurso = {
    'nombre': nombre,
    'preceptorId': _uid,
    'creadoEn': FieldValue.serverTimestamp(),
  };

  // Solo agrega tecnicatura si fue seleccionada
  if (tecnicatura != null) {
    datosCurso['tecnicatura'] = tecnicatura;
  }

  await _db.collection('cursos').add(datosCurso);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Curso "$nombre" creado'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Panel Preceptor'),
        backgroundColor: Colors.teal,
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

      // Botón para crear curso nuevo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogCrearCurso,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo curso'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        // Escucha en tiempo real los cursos de este preceptor
        stream: _db
            .collection('cursos')
            .where('preceptorId', isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tenés cursos todavía.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tocá el botón para crear uno.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final cursos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              final nombre = curso['nombre'];
              final cursoId = curso.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.class_, color: Colors.teal),
                  ),
                  title: Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                                  curso.data() is Map && (curso.data() as Map).containsKey('tecnicatura')
                                      ? (curso.data() as Map<String, dynamic>)['tecnicatura']
                                      : 'Tocá para gestionar',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navega al detalle del curso
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CursoDetalleScreen(
                          cursoId: cursoId,
                          nombreCurso: nombre,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}