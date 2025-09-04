import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.5;

  late AnimationController _textController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Animate logo (slow motion)
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Text slide animation (slowed down to 3s)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _textController.forward();
    });

    // Glow animation (slowed down to 5s cycle)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Navigate to home after 7 seconds (longer)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Get.offAllNamed('/');
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 0, 162, 141), Color(0xFF0B2A78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Falling stars (slow)
          const Positioned.fill(child: _FallingStars()),
          // Floating dots (slow)
          const Positioned.fill(child: _FloatingDots()),
          // Center logo
          SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(seconds: 3), // slower fade
                  opacity: _opacity,
                  child: AnimatedScale(
                    scale: _scale,
                    duration: const Duration(seconds: 3), // slower zoom
                    curve: Curves.easeOutBack,
                    child: Image.asset(
                      'assets/app_icon/khawin_admin.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Floating dots slow motion
class _FloatingDots extends StatefulWidget {
  const _FloatingDots();

  @override
  State<_FloatingDots> createState() => _FloatingDotsState();
}

class _FloatingDotsState extends State<_FloatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(
      15,
      (index) => Offset((index * 50.0) % 300, (index * 80.0) % 600),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // much slower dots
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(painter: _DotsPainter(_dots, _controller.value));
      },
    );
  }
}

class _DotsPainter extends CustomPainter {
  final List<Offset> dots;
  final double progress;

  _DotsPainter(this.dots, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    for (final dot in dots) {
      final dx = (dot.dx + progress * 50) % size.width;
      final dy = (dot.dy + progress * 50) % size.height;
      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => true;
}

// Falling stars slow motion
class _FallingStars extends StatefulWidget {
  const _FallingStars();

  @override
  State<_FallingStars> createState() => _FallingStarsState();
}

class _FallingStarsState extends State<_FallingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _stars;
  final int _count = 20;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(
      _count,
      (index) => Offset((index * 40.0) % 400, (index * 60.0) % 800),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), //much slower stars
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(painter: _StarsPainter(_stars, _controller.value));
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  final List<Offset> stars;
  final double progress;

  _StarsPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.4);
    for (final star in stars) {
      double dx = star.dx;
      double dy = (star.dy + progress * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}
