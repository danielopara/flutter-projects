import 'package:flutter/material.dart';

class GraidentDecorator extends StatelessWidget {
  const GraidentDecorator({super.key, required this.start, required this.end});

  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: const Text('Hello World', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}
