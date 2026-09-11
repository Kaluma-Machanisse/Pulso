import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/pulso_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _draw;
  late final Animation<double> _beat;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    // A linha desenha-se nos primeiros ~65% do tempo…
    _draw = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    // …e depois dá uma batida curta.
    _beat = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 72),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 8),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20),
    ]).animate(_c);
    _c.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    // Mínimo de 2,5 s para a animação do splash correr toda.
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Sessão do Supabase persiste entre arranques — se já estiveres ligado,
    // entra direto; senão vai para o login (com opção de continuar offline).
    final destino =
        AuthService.isLoggedIn ? const HomeScreen() : const LoginScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? PulsoColors.bgDark : PulsoColors.bgLight;
    final ink = isDark ? PulsoColors.inkDark : PulsoColors.inkLight;
    final primary = isDark ? PulsoColors.primaryDark : PulsoColors.primaryLight;
    final muted = isDark ? PulsoColors.mutedDark : PulsoColors.mutedLight;
    final noMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'pulso',
                  style: TextStyle(
                    fontFamily: 'FamiljenGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 64,
                    letterSpacing: -1.5,
                    color: ink,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => CustomPaint(
                    size: const Size(232, 34),
                    painter: _PulseLinePainter(
                      progress: noMotion ? 1 : _draw.value,
                      beat: noMotion ? 0 : _beat.value,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        color: primary,
                        backgroundColor: isDark
                            ? PulsoColors.lineDark
                            : PulsoColors.lineLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: muted,
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

class _PulseLinePainter extends CustomPainter {
  final double progress; // 0..1 — quanto da linha já foi desenhado
  final double beat; // 0..1 — pequeno impulso vertical no pico
  final Color color;

  _PulseLinePainter({
    required this.progress,
    required this.beat,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final mid = size.height * 0.62;
    final lift = 6 * beat;

    final path = Path()
      ..moveTo(0, mid)
      ..lineTo(w * 0.40, mid)
      ..lineTo(w * 0.44, mid)
      ..lineTo(w * 0.49, mid - 16 - lift)
      ..lineTo(w * 0.55, mid + 12)
      ..lineTo(w * 0.59, mid)
      ..lineTo(w, mid);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress.clamp(0, 1));

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_PulseLinePainter old) =>
      old.progress != progress || old.beat != beat || old.color != color;
}
