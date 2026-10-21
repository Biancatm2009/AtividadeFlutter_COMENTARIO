import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  // Paleta escura com destaque laranja/rosa
  static const _fundo = Color(0xFF131313);
  static const _cartao = Color(0xFF1E1E1E);
  static const _laranja = Color(0xFFFF8A3D);
  static const _rosa = Color(0xFFFF4F9A);
  static const _gradiente = LinearGradient(colors: [_laranja, _rosa]);

  String _data(DateTime? d) {
    if (d == null) return '—';
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  /// Quantidade de documentos de uma coleção que pertencem ao usuário.
  Stream<int> _total(String colecao, String uid) {
    return FirebaseFirestore.instance
        .collection(colecao)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.usuario;
    final nome = AuthService.nomeUsuario;
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: _fundo,
      body: Stack(
        children: [
          // Brilhos coloridos de fundo
          Positioned(
            top: -120,
            right: -100,
            child: _brilho(_laranja, 380),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _brilho(const Color(0xFF8E44FF), 400),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botão voltar (quadrado branco)
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.arrow_back,
                                color: Colors.black, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Avatar com anel em degradê
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _gradiente,
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: _cartao,
                          child: Text(
                            inicial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'PERFIL',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Nome com texto em degradê
                      ShaderMask(
                        shaderCallback: (b) =>
                            _gradiente.createShader(Offset.zero & b.size),
                        child: Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 28),

                      // Números do usuário
                      Row(
                        children: [
                          Expanded(
                            child: _Estatistica(
                              rotulo: 'PUBLICAÇÕES',
                              total: _total('publicacoes', user.uid),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Estatistica(
                              rotulo: 'COMENTÁRIOS',
                              total: _total('comentarios', user.uid),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Informações da conta
                      const Text(
                        'Minhas informações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _cartao,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            _linha(Icons.badge_outlined, 'Nome', nome),
                            const Divider(color: Colors.white10, height: 1),
                            _linha(Icons.email_outlined, 'E-mail',
                                user.email ?? '—'),
                            const Divider(color: Colors.white10, height: 1),
                            _linha(Icons.calendar_today_outlined,
                                'Membro desde',
                                _data(user.metadata.creationTime)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botão sair (pílula branca)
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            // Volta para a primeira tela e encerra a sessão;
                            // o main.dart mostra o Login automaticamente.
                            Navigator.of(context)
                                .popUntil((rota) => rota.isFirst);
                            AuthService.sair();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 28),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text(
                            'Sair da conta',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brilho(Color cor, double tamanho) {
    return IgnorePointer(
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [cor.withAlpha(90), cor.withAlpha(0)],
          ),
        ),
      ),
    );
  }

  Widget _linha(IconData icone, String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icone, color: _laranja, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão com um número em destaque e um rótulo pequeno embaixo.
class _Estatistica extends StatelessWidget {
  final String rotulo;
  final Stream<int> total;

  const _Estatistica({required this.rotulo, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PerfilPage._cartao,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<int>(
            stream: total,
            builder: (context, snapshot) {
              final texto = snapshot.hasData ? '${snapshot.data}' : '—';
              return Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}