import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late Animation<Color?> _backgroundAnimation;
  List<String> letters = "STM-LOST-AI".split('');
  List<AnimationController> letterControllers = [];
  List<Animation<Offset>> letterAnimations = [];
  List<Animation<double>> letterScales = [];
  List<Animation<double>> letterRotation = [];
  List<Offset> dots = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
      lowerBound: 0.5,
      upperBound: 1.5,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: Colors.indigo.shade900,
      end: Colors.deepPurple.shade800,
    ).animate(_controller);

    _controller.forward();

    for (int i = 0; i < letters.length; i++) {
      var letterController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000 + i * 120),
      );

      double startX = Random().nextDouble() * 2 - 1;
      double startY = Random().nextDouble() * 2 - 1;

      var letterAnimation = Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: letterController,
        curve: Curves.easeOutBack,
      ));

      var scaleAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: letterController,
        curve: Curves.elasticOut,
      ));

      var rotationAnimation = Tween<double>(
        begin: Random().nextDouble() * 1.5 - 0.75,
        end: 0,
      ).animate(CurvedAnimation(
        parent: letterController,
        curve: Curves.easeOut,
      ));

      letterControllers.add(letterController);
      letterAnimations.add(letterAnimation);
      letterScales.add(scaleAnimation);
      letterRotation.add(rotationAnimation);

      Future.delayed(Duration(milliseconds: i * 180), () {
        letterController.forward();
      });
    }

    Timer.periodic(Duration(milliseconds: 400), (timer) {
      setState(() {
        if (dots.length > 80) dots.clear();
        dots.add(Offset(
          Random().nextDouble() * MediaQuery.of(context).size.width,
          Random().nextDouble() * MediaQuery.of(context).size.height,
        ));
      });
    });

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 900),
            pageBuilder: (_, __, ___) => LoginPage(),
            transitionsBuilder: (_, animation, __, child) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    for (var c in letterControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _backgroundAnimation.value ?? Colors.indigo,
                      Colors.deepPurple.shade900
                    ],
                    center: Alignment.center,
                    radius: 1.5,
                  ),
                ),
              ),

              Positioned.fill(
                child: CustomPaint(
                  painter: DotsPainter(dots),
                ),
              ),

              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _glowController.value * 0.3,

                    );
                  },
                ),
              ),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(letters.length, (index) {
                    return AnimatedBuilder(
                      animation: letterControllers[index],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: letterAnimations[index].value *
                              MediaQuery.of(context).size.width *
                              0.4,
                          child: Transform.scale(
                            scale: letterScales[index].value,
                            child: Transform.rotate(
                              angle: letterRotation[index].value,
                              child: Text(
                                letters[index],
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'orbitron',
                                  letterSpacing: 2.0,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blueAccent.withOpacity(0.7),
                                      blurRadius: 20,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DotsPainter extends CustomPainter {
  final List<Offset> dots;
  DotsPainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (var dot in dots) {
      canvas.drawCircle(dot, Random().nextDouble() * 3 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
