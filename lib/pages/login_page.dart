import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
import '../services/auth_service.dart';
import 'cadastro_page.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  // Paleta da tela
  static const _fundo = Color(0xFF023047);
  static const _campo = Color(0xFF1B4A62);
  static const _verde = Color(0xFF00E676);
 
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
 
  Future<void> _entrar() async {
    setState(() => _carregando = true);
    try {
      await AuthService.entrar(_email.text.trim(), _senha.text);
      // O StreamBuilder do main.dart leva para a HomePage automaticamente
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: ${e.code}')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }
 
  @override
  void dispose() {
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
      fillColor: _campo,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _verde, width: 1.5),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      body: Stack(
        children: [
          // Ondas decorativas no rodapé
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: IgnorePointer(
              child: CustomPaint(painter: _OndasPainter()),
            ),
          ),
 
          // Conteúdo
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone no topo
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: _campo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.forum_rounded,
                            color: _verde, size: 32),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Entre e participe das discussões do mural!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 32),
 
                      // E-mail
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: _verde,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _decoracao('E-mail', Icons.email_outlined),
                      ),
                      const SizedBox(height: 14),
 
                      // Senha
                      TextField(
                        controller: _senha,
                        obscureText: true,
                        cursorColor: _verde,
                        onSubmitted: (_) => _carregando ? null : _entrar(),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracao('Senha', Icons.lock_outline),
                      ),
                      const SizedBox(height: 24),
 
                      // Botão Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _carregando ? null : _entrar,
                          style: FilledButton.styleFrom(
                            backgroundColor: _verde,
                            foregroundColor: _fundo,
                            disabledBackgroundColor: _verde.withAlpha(120),
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
                                    color: _fundo,
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
 
                      // Ir para o cadastro
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CadastroPage()),
                        ),
                        child: const Text(
                          'Não tem conta? Cadastre-se',
                          style: TextStyle(color: _verde, fontSize: 13),
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
 
/// Desenha duas ondas no rodapé da tela.
class _OndasPainter extends CustomPainter {
  const _OndasPainter();
 
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
 
    final onda1 = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.25, h * 0.0, w * 0.5, h * 0.3)
      ..quadraticBezierTo(w * 0.8, h * 0.62, w, h * 0.2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(onda1, Paint()..color = const Color(0x24FFFFFF));
 
    final onda2 = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.3, h * 0.32, w * 0.6, h * 0.6)
      ..quadraticBezierTo(w * 0.85, h * 0.82, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(onda2, Paint()..color = const Color(0xFFE9EFF4));
  }
 
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}