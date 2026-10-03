import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: CAppTheme.darkTheme,
      theme: CAppTheme.lightTheme,
    );
  }
}
