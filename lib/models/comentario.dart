import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String texto;
  final String nome;
  final String uid;
  final String postId;
  final DateTime? criadoEm;

  Comentario({
    required this.id,
    required this.texto,
    required this.nome,
    required this.uid,
    required this.postId,
    this.criadoEm,
  });

  factory Comentario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Comentario(
      id: doc.id,
      texto: d['texto'] ?? '',
      nome: d['nome'] ?? 'Anônimo',
      uid: d['uid'] ?? '',
      postId: d['postId'] ?? '',
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate(),
    );
  }
}
