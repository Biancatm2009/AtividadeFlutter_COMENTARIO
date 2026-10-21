import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/comentario.dart';
import '../models/publicacao.dart';
import '../services/auth_service.dart';
import '../services/comentario_service.dart';

class ComentariosPage extends StatefulWidget {
  final Publicacao publicacao;

  const ComentariosPage({super.key, required this.publicacao});

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  // Paleta da tela
  static const _fundo = Color(0xFFAEB8E0);
  static const _painel = Color(0xFFF5F7FE);
  static const _azul = Color(0xFF5676F5);
  static const _balaoOutros = Color(0xFFE9ECF7);

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  int _totalAnterior = 0;

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    _controller.clear();
    await ComentarioService.adicionar(widget.publicacao.id, texto);
  }

  // Rola para o último comentário quando chega um novo
  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _hora(DateTime? data) {
    if (data == null) return 'enviando...';
    final h = data.hour.toString().padLeft(2, '0');
    final m = data.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meuUid = AuthService.usuario.uid;
    final post = widget.publicacao;
    final larguraBalao = math.min(MediaQuery.of(context).size.width * 0.72, 460.0);

    return Scaffold(
      backgroundColor: _fundo,
      appBar: AppBar(
        backgroundColor: _fundo,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          post.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            decoration: const BoxDecoration(
              color: _painel,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Publicação selecionada (fixa no topo)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _balaoOutros),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.push_pin_outlined,
                              size: 16, color: _azul),
                          const SizedBox(width: 6),
                          Text(
                            'Publicação de ${post.nome}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(post.texto, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),

                // Comentários em tempo real, só desta publicação
                Expanded(
                  child: StreamBuilder<List<Comentario>>(
                    stream: ComentarioService.doPost(post.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comentarios = snapshot.data!;
                      if (comentarios.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum comentário ainda.\nSeja o primeiro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black45),
                          ),
                        );
                      }

                      if (comentarios.length != _totalAnterior) {
                        _totalAnterior = comentarios.length;
                        _rolarParaFim();
                      }

                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: comentarios.length,
                        itemBuilder: (context, i) {
                          final c = comentarios[i];
                          final meu = c.uid == meuUid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: meu
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: meu
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Só o autor vê o botão de excluir
                                    if (meu)
                                      IconButton(
                                        tooltip: 'Excluir comentário',
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.redAccent),
                                        onPressed: () =>
                                            ComentarioService.excluir(c.id),
                                      ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: larguraBalao),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: meu ? _azul : _balaoOutros,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(20),
                                            topRight: const Radius.circular(20),
                                            bottomLeft: Radius.circular(
                                                meu ? 20 : 4),
                                            bottomRight: Radius.circular(
                                                meu ? 4 : 20),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!meu) ...[
                                              Text(
                                                c.nome,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _azul,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            Text(
                                              c.texto,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: meu
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4, left: 6, right: 6),
                                  child: Text(
                                    meu
                                        ? 'Você • ${_hora(c.criadoEm)}'
                                        : _hora(c.criadoEm),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.black45),
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

                // Campo de envio
                SafeArea(
                  top: false,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    padding: const EdgeInsets.only(left: 18, right: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _enviar(),
                            decoration: const InputDecoration(
                              hintText: 'Escreva um comentário...',
                              hintStyle: TextStyle(color: Colors.black38),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: 'Enviar',
                          style: IconButton.styleFrom(backgroundColor: _azul),
                          icon: const Icon(Icons.send_rounded,
                              size: 20, color: Colors.white),
                          onPressed: _enviar,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}