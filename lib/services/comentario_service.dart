import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comentario.dart';
import 'auth_service.dart';

class ComentarioService {
  static final _col = FirebaseFirestore.instance.collection('comentarios');

  /// Stream em tempo real apenas dos comentários de UMA publicação.
  /// A ordenação é feita no app para não exigir índice composto.
  static Stream<List<Comentario>> doPost(String postId) {
    return _col.where('postId', isEqualTo: postId).snapshots().map((s) {
      final lista = s.docs.map(Comentario.fromDoc).toList();
      lista.sort((a, b) {
        final ta = a.criadoEm ?? DateTime.now();
        final tb = b.criadoEm ?? DateTime.now();
        return ta.compareTo(tb);
      });
      return lista;
    });
  }

  static Future<void> adicionar(String postId, String texto) {
    return _col.add({
      'texto': texto,
      'nome': AuthService.nomeUsuario,
      'uid': AuthService.usuario.uid,
      'postId': postId,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> excluir(String comentarioId) {
    return _col.doc(comentarioId).delete();
  }
}
