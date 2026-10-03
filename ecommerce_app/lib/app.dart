import 'package:ecommerce_app/features/authentication/screens/onboarding.dart';
import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: CAppTheme.darkTheme,
      theme: CAppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
