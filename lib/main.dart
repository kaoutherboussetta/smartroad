import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/OnboardingAnalysisPage.dart';
import 'connexion/login_page.dart';
import 'connexion/register_page.dart';
import 'connexion/forgot_password_page.dart';
import 'providers/auth_provider.dart';
import 'widgets/video_background.dart';

//import 'screens/OnboardingAlertPage.dart';
//import 'screens/OnboardingNavigationPage.dart';
//import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Précharge la vidéo d’arrière-plan pour qu’elle s’affiche dès l’ouverture de la connexion (sans fond noir)
  VideoBackground.preload();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Ajoutez d'autres providers si nécessaire
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartRoad',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Inter', // Vous pouvez choisir une police
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => CompleteOnboardingPage(),
          '/onboarding-analysis': (context) => CompleteOnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          //'/onboarding-alert': (context) => OnboardingAlertPage(),
          //'/onboarding-navigation': (context) => OnboardingNavigationPage(),
          //'/home': (context) => HomePage(),
        },
      ),
    );
  }
}