import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/products/screens/products_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return authState.when(
      data: (user) =>
          user == null ? const LoginScreen() : const ProductsScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const LoginScreen(),
    );
  }
}
