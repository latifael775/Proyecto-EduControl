import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/token_service.dart';

class CursoDetalleScreen extends StatefulWidget {
  final String cursoId;
  final String nombreCurso;

  const CursoDetalleScreen({
    super.key,
    required this.cursoId,
    required this.nombreCurso,
  });

  @override
  State<CursoDetalleScreen> createState() => _CursoDetalleScreenState();
}

class _CursoDetalleScreenState extends State<CursoDetalleScreen>
    with SingleTickerProviderStateMixin {
  final _db = FirebaseFirestore.instance;
  final _tokenService = TokenService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 pestañas: Lista completa, Grupo A, Grupo B
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Muestra el token generado
  void _mostrarToken(String token, String nombreAlumno, String tipo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Token de $tipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Token para: $nombreAlumno'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    token,
                    style: const TextStyle(
                      fontSize: 22,
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

  // Dialog para agregar alumno al curso
 void _mostrarDialogAgregarAlumno() {
  final nombreController = TextEditingController();
  String grupoSeleccionado = 'A';

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Agregar alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del alumno',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            const Text(
              'Grupo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Selector simple entre A y B
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setStateDialog(() => grupoSeleccionado = 'A'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: grupoSeleccionado == 'A'
                            ? Colors.teal
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Grupo A',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: grupoSeleccionado == 'A'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setStateDialog(() => grupoSeleccionado = 'B'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: grupoSeleccionado == 'B'
                            ? Colors.teal
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Grupo B',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: grupoSeleccionado == 'B'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              if (nombre.isEmpty) return;
              Navigator.pop(context);
              await _agregarAlumno(nombre, grupoSeleccionado);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
} 
  // Agrega el alumno a Firestore y genera tokens
  Future<void> _agregarAlumno(String nombre, String grupo) async {
    // Agrega el alumno a la subcolección del curso
    final alumnoRef = await _db
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('alumnos')
        .add({
      'nombre': nombre,
      'grupo': grupo,
      'cursoId': widget.cursoId,
      'nombreCurso': widget.nombreCurso,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // Genera token para el alumno
    final tokenAlumno = await _tokenService.crearTokenAlumno(nombre);

    // Guarda el tokenId en el alumno para referencia
    await alumnoRef.update({'tokenAlumno': tokenAlumno});

    // Genera token para la familia
    final tokenFamilia = await _tokenService.crearTokenFamilia(
      alumnoRef.id,
      nombre,
    );

    await alumnoRef.update({'tokenFamilia': tokenFamilia});

    if (mounted) {
      // Muestra ambos tokens
      _mostrarTokensAlumno(tokenAlumno, tokenFamilia, nombre);
    }
  }

  // Muestra los dos tokens generados (alumno y familia)
  void _mostrarTokensAlumno(
      String tokenAlumno, String tokenFamilia, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tokens para $nombre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTokenItem('Token Alumno', tokenAlumno, Colors.teal),
            const SizedBox(height: 12),
            _buildTokenItem('Token Familia', tokenFamilia, Colors.orange),
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

  Widget _buildTokenItem(String titulo, String token, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                token,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$titulo copiado')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Lista de alumnos filtrada por grupo
  Widget _buildListaAlumnos(String? grupo) {
  Stream<QuerySnapshot> stream;

  if (grupo == null) {
    // Lista completa — todos los alumnos ordenados por nombre
    stream = _db
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('alumnos')
        .orderBy('nombre')
        .snapshots();
  } else {
    // Filtrado por grupo — sin orderBy para evitar el índice
    stream = _db
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('alumnos')
        .where('grupo', isEqualTo: grupo)
        .snapshots();
  }

  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                grupo == null
                    ? 'No hay alumnos en este curso.'
                    : 'No hay alumnos en el Grupo $grupo.',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final alumnos = snapshot.data!.docs;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alumnos.length,
        itemBuilder: (context, index) {
          final alumno = alumnos[index].data() as Map<String, dynamic>;
          final alumnoId = alumnos[index].id;
          final nombre = alumno['nombre'] ?? '';
          final grupoAlumno = alumno['grupo'] ?? 'A';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: grupoAlumno == 'A'
                    ? Colors.teal.shade100
                    : Colors.orange.shade100,
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: grupoAlumno == 'A' ? Colors.teal : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(nombre),
              subtitle: Text('Grupo $grupoAlumno'),
              trailing: PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'tokens',
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key_outlined),
                        SizedBox(width: 8),
                        Text('Ver tokens'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (valor) {
                  if (valor == 'tokens') {
                    _mostrarToken(
                      alumno['tokenAlumno'] ?? 'Sin token',
                      nombre,
                      'Alumno',
                    );
                  } else if (valor == 'editar') {
                    _mostrarDialogEditarAlumno(alumnoId, alumno);
                  } else if (valor == 'eliminar') {
                    _confirmarEliminar(alumnoId, nombre);
                  }
                },
              ),
            ),
          );
        },
      );
    },
  );
}

  // Dialog para editar alumno
  void _mostrarDialogEditarAlumno(
      String alumnoId, Map<String, dynamic> alumno) {
    final nombreController =
        TextEditingController(text: alumno['nombre']);
    String grupoSeleccionado = alumno['grupo'] ?? 'completo';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar alumno'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del alumno',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Grupo:'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'completo', label: Text('Completo')),
                  ButtonSegment(value: 'A', label: Text('Grupo A')),
                  ButtonSegment(value: 'B', label: Text('Grupo B')),
                ],
                selected: {grupoSeleccionado},
                onSelectionChanged: (valor) {
                  setStateDialog(() => grupoSeleccionado = valor.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db
                    .collection('cursos')
                    .doc(widget.cursoId)
                    .collection('alumnos')
                    .doc(alumnoId)
                    .update({
                  'nombre': nombreController.text.trim(),
                  'grupo': grupoSeleccionado,
                });
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // Confirma antes de eliminar un alumno
  void _confirmarEliminar(String alumnoId, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: Text('¿Seguro que querés eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db
                  .collection('cursos')
                  .doc(widget.cursoId)
                  .collection('alumnos')
                  .doc(alumnoId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.nombreCurso),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Lista completa'),
            Tab(text: 'Grupo A'),
            Tab(text: 'Grupo B'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogAgregarAlumno,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar alumno'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaAlumnos(null),   // Lista completa
          _buildListaAlumnos('A'),    // Grupo A
          _buildListaAlumnos('B'),    // Grupo B
        ],
      ),
    );
  }
}