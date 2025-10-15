import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Check session and navigate after animation
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Get current session
      final session = Supabase.instance.client.auth.currentSession;

      print('🔍 Splash: Checking session...');
      print('Session exists: ${session != null}');

      if (session != null) {
        print('✅ Splash: User logged in, navigating to /home');
        context.go('/home');
      } else {
        print('❌ Splash: No session, navigating to /login');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Splash: Error checking session: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // splash background color
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/logo.png',
            width: 200,
            height: 200,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.medical_services,
                size: 96,
                color: Colors.indigo,
              );
            },
          ),
        ),
      ),
    );
  }
}
