import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withValues(alpha: 0.07), colorScheme.surface],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: child),
        ),
      ),
    );
  }
}
