import 'package:flutter/material.dart';

/// Paleta única do app (a mesma do login).
class AppColors {
  static const fundo = Color(0xFF023047); // azul-petróleo
  static const cartao = Color(0xFF0B3C57); // cartões e painéis
  static const campo = Color(0xFF1B4A62); // campos e balões
  static const verde = Color(0xFF00E676); // cor principal (botões)
  static const laranja = Color(0xFFFF8A3D); // detalhe
  static const rosa = Color(0xFFFF4F9A); // detalhe
  static const onda = Color(0xFFE9EFF4); // ondas do rodapé
  static const gradiente = LinearGradient(colors: [laranja, rosa]);
}

/// Círculo com brilho suave, usado como decoração de fundo.
class Brilho extends StatelessWidget {
  final Color cor;
  final double tamanho;

  const Brilho({super.key, required this.cor, required this.tamanho});

  @override
  Widget build(BuildContext context) {
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
}

/// Duas ondas no rodapé da tela.
class OndasPainter extends CustomPainter {
  const OndasPainter();

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
    canvas.drawPath(onda2, Paint()..color = AppColors.onda);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}