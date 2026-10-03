import 'package:ecommerce_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: CAppTheme.darkTheme,
      theme: CAppTheme.lightTheme,
    );
  }
}
