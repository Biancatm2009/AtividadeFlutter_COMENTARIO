import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User get usuario => _auth.currentUser!;

  static String get nomeUsuario =>
      usuario.displayName ?? usuario.email ?? 'Anônimo';

  static Stream<User?> get estado => _auth.authStateChanges();

  static Future<void> entrar(String email, String senha) {
    return _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  static Future<void> cadastrar(String nome, String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    await cred.user!.updateDisplayName(nome);
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(cred.user!.uid)
        .set({
      'nome': nome,
      'email': email,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sair() => _auth.signOut();
}
