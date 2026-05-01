class UsuarioModel {
  final String uid;
  final String email;
  final String nombre;
  final String rol; // 'alumno', 'profesor' o 'familia'

  UsuarioModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  // Convierte el modelo a un Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'rol': rol,
    };
  }

  // Crea un modelo desde un documento de Firestore
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      rol: map['rol'] ?? '',
    );
  }
}