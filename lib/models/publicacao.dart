import 'package:cloud_firestore/cloud_firestore.dart';

class Publicacao {
  final String id;
  final String texto;
  final String nome;
  final String uid;

  Publicacao({
    required this.id,
    required this.texto,
    required this.nome,
    required this.uid,
  });

  factory Publicacao.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Publicacao(
      id: doc.id,
      texto: d['texto'] ?? '',
      nome: d['nome'] ?? 'Anônimo',
      uid: d['uid'] ?? '',
    );
  }
}
