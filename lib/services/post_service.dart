import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/publicacao.dart';
import 'auth_service.dart';

class PostService {
  static final _col = FirebaseFirestore.instance.collection('publicacoes');

  static Stream<List<Publicacao>> publicacoes() {
    return _col
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Publicacao.fromDoc).toList());
  }

  static Future<void> publicar(String texto) {
    return _col.add({
      'texto': texto,
      'nome': AuthService.nomeUsuario,
      'uid': AuthService.usuario.uid,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> excluir(String id) => _col.doc(id).delete();
}
