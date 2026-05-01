import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class TokenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Genera un token aleatorio de 8 caracteres
  String _generarCodigo() {
    const caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
        8, (_) => caracteres[random.nextInt(caracteres.length)]).join();
  }

  // Crea un token para profesor
  Future<String> crearTokenProfesor() async {
    final codigo = _generarCodigo();
    await _db.collection('tokens').doc(codigo).set({
      'codigo': codigo,
      'tipo': 'profesor',
      'usado': false,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return codigo;
  }

  // Crea un token para preceptor
  Future<String> crearTokenPreceptor() async {
    final codigo = _generarCodigo();
    await _db.collection('tokens').doc(codigo).set({
      'codigo': codigo,
      'tipo': 'preceptor',
      'usado': false,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return codigo;
  }

  // Crea un token para alumno
  Future<String> crearTokenAlumno(String nombreAlumno) async {
    final codigo = _generarCodigo();
    await _db.collection('tokens').doc(codigo).set({
      'codigo': codigo,
      'tipo': 'alumno',
      'usado': false,
      'nombreAlumno': nombreAlumno,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return codigo;
  }

  // Crea un token para familia vinculado a un alumno
  Future<String> crearTokenFamilia(String alumnoId, String nombreAlumno) async {
    final codigo = _generarCodigo();
    await _db.collection('tokens').doc(codigo).set({
      'codigo': codigo,
      'tipo': 'familia',
      'usado': false,
      'alumnoId': alumnoId,
      'nombreAlumno': nombreAlumno,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return codigo;
  }

  // Valida un token y retorna sus datos
  Future<Map<String, dynamic>?> validarToken(String codigo) async {
    final doc = await _db.collection('tokens').doc(codigo.toUpperCase()).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    if (data['usado'] == true) return null;
    return data;
  }

  // Marca el token como usado
  Future<void> marcarTokenUsado(String codigo) async {
    await _db.collection('tokens').doc(codigo.toUpperCase()).update({
      'usado': true,
      'usadoEn': FieldValue.serverTimestamp(),
    });
  }
}