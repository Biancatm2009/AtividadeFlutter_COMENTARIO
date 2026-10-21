import 'package:flutter/material.dart';

import '../models/publicacao.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../theme/app_theme.dart';
import 'comentarios_page.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  Future<void> _publicar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    _controller.clear();
    await PostService.publicar(texto);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meuUid = AuthService.usuario.uid;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Mural',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilPage()),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: AuthService.sair,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Brilhos de fundo
          const Positioned(
            top: -120,
            right: -100,
            child: Brilho(cor: AppColors.laranja, tamanho: 360),
          ),
          const Positioned(
            bottom: -140,
            left: -120,
            child: Brilho(cor: AppColors.verde, tamanho: 380),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Campo para nova publicação
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    padding: const EdgeInsets.only(left: 18, right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.campo,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _publicar(),
                            cursorColor: AppColors.verde,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Escreva uma publicação...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: _publicar,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            foregroundColor: AppColors.fundo,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Publicar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ),

                  // Lista de publicações em tempo real
                  Expanded(
                    child: StreamBuilder<List<Publicacao>>(
                      stream: PostService.publicacoes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Erro: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.verde),
                          );
                        }
                        final posts = snapshot.data!;
                        if (posts.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhuma publicação ainda.\nSeja o primeiro a publicar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: posts.length,
                          itemBuilder: (context, i) {
                            final p = posts[i];
                            final minha = p.uid == meuUid;
                            final inicial = p.nome.isNotEmpty
                                ? p.nome[0].toUpperCase()
                                : '?';

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cartao,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Autor
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.gradiente,
                                        ),
                                        child: CircleAvatar(
                                          radius: 17,
                                          backgroundColor: AppColors.cartao,
                                          child: Text(
                                            inicial,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          p.nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      // Só o autor vê o botão de excluir
                                      if (minha)
                                        IconButton(
                                          tooltip: 'Excluir publicação',
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.rosa),
                                          onPressed: () =>
                                              PostService.excluir(p.id),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Texto
                                  Text(
                                    p.texto,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                      height: 1, color: Colors.white10),

                                  // Botão de comentários
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ComentariosPage(publicacao: p),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          size: 18,
                                          color: AppColors.verde),
                                      label: const Text(
                                        'Comentários',
                                        style:
                                            TextStyle(color: AppColors.verde),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}