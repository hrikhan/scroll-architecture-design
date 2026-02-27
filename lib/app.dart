import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'core/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF57224)),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const AuthGate(),
    );
  }
}
