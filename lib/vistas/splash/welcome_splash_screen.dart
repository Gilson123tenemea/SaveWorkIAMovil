
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../sesion/user_session.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late AnimationController _rippleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rippleAnimation;

  final Color primaryBlue = const Color(0xFF1976D2); // Azul principal
  final Color accentBlue = const Color(0xFF2196F3); // Azul acento
  final Color darkBlue = const Color(0xFF0D47A1); // Azul oscuro
  final Color lightBlue = const Color(0xFF64B5F6); // Azul claro

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    await _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final session = UserSession();
    bool tieneSesion = await session.cargarSesion();

    // Fade out
    await _fadeController.forward();

    if (!mounted) return;

    String ruta;
    if (tieneSesion) {
      print('🔓 Sesión encontrada - Redirigiendo a: ${session.rol}');

      if (session.rol == 'supervisor') {
        ruta = '/supervisor/menu';
      } else if (session.rol == 'inspector') {
        ruta = '/inspector/menu';
      } else if (session.rol == 'trabajador') {
        ruta = '/trabajador/menu';
      } else {
        ruta = '/login';
      }
    } else {
      print('🔐 No hay sesión - Mostrando login');
      ruta = '/login';
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, ruta);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 🌊 Ondas de fondo animadas
            _buildAnimatedRipples(),

            // 📱 Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🛡️ Logo principal con animación
                  _buildAnimatedLogo(),

                  const SizedBox(height: 40),

                  // 📝 Texto animado
                  _buildAnimatedText(),

                  const SizedBox(height: 20),

                  // ⚙️ Iconos de EPP
                  _buildSafetyIcons(),
                ],
              ),
            ),

            // ⏳ Indicador de carga en la parte inferior
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  // 🌊 Ondas animadas de fondo
  Widget _buildAnimatedRipples() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final progress = (_rippleAnimation.value + delay) % 1.0;

            return Center(
              child: Container(
                width: 300 * progress,
                height: 300 * progress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentBlue.withOpacity((1 - progress) * 0.3),
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // 🛡️ Logo animado central
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value * 0.1 * math.pi,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlue, accentBlue],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // 📝 Texto animado
  Widget _buildAnimatedText() {
    return FadeTransition(
      opacity: _textOpacity,
      child: Column(
        children: [
          Text(
            'SafetyTrack',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: darkBlue,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seguridad Industrial',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ⚙️ Iconos de equipos de seguridad
  Widget _buildSafetyIcons() {
    final icons = [
      Icons.construction, // Casco
      Icons.shield, // Protección
      Icons.visibility, // Gafas
      Icons.back_hand, // Guantes
    ];

    return FadeTransition(
      opacity: _textOpacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: icons.asMap().entries.map((entry) {
            final index = entry.key;
            final icon = entry.value;

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 800 + (index * 200)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ⏳ Indicador de carga
  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _textOpacity,
        child: Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(accentBlue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}