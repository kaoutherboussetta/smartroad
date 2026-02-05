import 'package:flutter/material.dart';
import 'screens/SplashVideoPage.dart';
import 'screens/OnboardingAnalysisPage.dart';
import 'connexion/login_page.dart';
import 'connexion/register_page.dart';
import 'connexion/forgot_password_page.dart';
//import 'screens/OnboardingAlertPage.dart';
//import 'screens/OnboardingNavigationPage.dart';
//import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashVideoPage(),
        '/onboarding-analysis': (context) => OnboardingAnalysisPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        //'/onboarding-alert': (context) => OnboardingAlertPage(),
        //'/onboarding-navigation': (context) => OnboardingNavigationPage(),
        //'/home': (context) => HomePage(),
      },
    );
  }
}
