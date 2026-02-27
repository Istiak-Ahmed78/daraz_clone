import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/products/presentation/pages/main_shell.dart'; // ← changed

void main() {
  runApp(const ProviderScope(child: DarazApp()));
}

class DarazApp extends StatelessWidget {
  const DarazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daraz Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

/// Routes between [LoginScreen] and [MainShell] based on auth state.
/// Uses [AuthStatus.initial] / [AuthStatus.loading] to show a splash
/// while the session check runs on startup.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.initial || AuthStatus.loading => const _SplashScreen(),
      AuthStatus.authenticated => const MainShell(), // ← changed
      _ => const LoginScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'daraz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
