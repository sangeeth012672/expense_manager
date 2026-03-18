import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/auth_bloc.dart';
import '../utils/app_colors.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      return;
    }

    // Check if authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bottom Right Shape (Purple)
            Transform(
              transform: Matrix4.translationValues(12, 12, 0)..setEntry(0, 1, -0.4),
              child: Container(
                width: 45,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF4351FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Top Left Shape (Light Blue)
            Transform(
              transform: Matrix4.translationValues(-12, -12, 0)..setEntry(0, 1, -0.4),
              child: Container(
                width: 45,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF0081FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
