import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- REGISTRO CON TOKEN ----
  Future<String?> registrarConToken({
    required String email,
    required String password,
    required String nombre,
    required String token,
    required String rolSeleccionado,
  }) async {
    try {
      final tokenDoc = await _db.collection('tokens').doc(token.toUpperCase()).get();

      if (!tokenDoc.exists) return 'El token no existe.';

      final tokenData = tokenDoc.data()!;

      if (tokenData['usado'] == true) return 'El token ya fue usado.';

      if (tokenData['tipo'] != rolSeleccionado) {
        return 'El token no corresponde al rol seleccionado.';
      }

      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credencial.user!.uid;

      Map<String, dynamic> datosUsuario = {
        'uid': uid,
        'email': email,
        'nombre': nombre,
        'rol': rolSeleccionado,
      };

      if (rolSeleccionado == 'familia') {
        datosUsuario['alumnoId'] = tokenData['alumnoId'];
        datosUsuario['nombreAlumno'] = tokenData['nombreAlumno'];
      }

      if (rolSeleccionado == 'alumno') {
        datosUsuario['nombreAlumno'] = tokenData['nombreAlumno'];
      }

      await _db.collection('usuarios').doc(uid).set(datosUsuario);

      await _db.collection('tokens').doc(token.toUpperCase()).update({
        'usado': true,
        'usadoEn': FieldValue.serverTimestamp(),
        'usuarioId': uid,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e.code);
    }
  }

  // ---- LOGIN ----
  Future<String?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e.code);
    }
  }

  // ---- CERRAR SESIÓN ----
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ---- OBTENER ROL ----
  Future<String?> obtenerRol() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data()?['rol'];
  }

  // ---- USUARIO ACTUAL ----
  User? get usuarioActual => _auth.currentUser;

  // ---- TRADUCIR ERRORES ----
  String _traducirError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ese email ya está registrado.';
      case 'invalid-email':
        return 'El email no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con ese email.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      default:
        return 'Ocurrió un error. Intentá de nuevo.';
    }
  }
}