import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initialize();
  final onboardingComplete = await DatabaseService.getSetting(
    'onboardingComplete',
  );
  runApp(ExpensarApp(showOnboarding: onboardingComplete != 'true'));
}

class ExpensarApp extends StatelessWidget {
  final bool showOnboarding;

  const ExpensarApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expensar',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: showOnboarding ? const OnboardingScreen() : const DashboardScreen(),
    );
  }
}
