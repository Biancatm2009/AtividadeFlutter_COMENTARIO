import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  Future<void> _cadastrar() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome')),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      await AuthService.cadastrar(nome, _email.text.trim(), _senha.text);
      if (mounted) Navigator.pop(context); // o main.dart abre a Home
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no cadastro: ${e.code}')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  InputDecoration _decoracao(String hint, IconData icone) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: Icon(icone, color: Colors.white54, size: 20),
      filled: true,
      fillColor: AppColors.campo,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.verde, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Ondas decorativas no rodapé
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: IgnorePointer(
              child: CustomPaint(painter: OndasPainter()),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.campo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_alt_1,
                            color: AppColors.verde, size: 32),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Cadastre-se para publicar e comentar no mural!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: _nome,
                        cursorColor: AppColors.verde,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracao('Nome', Icons.badge_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: AppColors.verde,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _decoracao('E-mail', Icons.email_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _senha,
                        obscureText: true,
                        cursorColor: AppColors.verde,
                        onSubmitted: (_) => _carregando ? null : _cadastrar(),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracao(
                            'Senha (mín. 6 caracteres)', Icons.lock_outline),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _carregando ? null : _cadastrar,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            foregroundColor: AppColors.fundo,
                            disabledBackgroundColor:
                                AppColors.verde.withAlpha(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _carregando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.fundo,
                                  ),
                                )
                              : const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Já tem conta? Entrar',
                          style: TextStyle(
                              color: AppColors.verde, fontSize: 13),
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
}