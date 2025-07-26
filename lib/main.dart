import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/auth_provider.dart';
import 'package:study_app/screens/splash_screen.dart';
import 'package:study_app/screens/auth/login_screen.dart';
import 'package:study_app/screens/home/main_screen.dart';
import 'package:study_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para armazenamento local
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  // Inicializar notificações
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: StudyApp(),
    ),
  );
}

class StudyApp extends ConsumerWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'StudyApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _buildHome(authState),
    );
  }
  
  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
        return const SplashScreen();
      case AuthStatus.loading:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}

