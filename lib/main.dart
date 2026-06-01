import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
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
  runApp(
    ProviderScope(
      child: ExpensarApp(showOnboarding: onboardingComplete != 'true'),
    ),
  );
}

class ExpensarApp extends ConsumerWidget {
  final bool showOnboarding;

  const ExpensarApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Expensar',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: themeMode,
      home: showOnboarding ? const OnboardingScreen() : const DashboardScreen(),
    );
  }
}
