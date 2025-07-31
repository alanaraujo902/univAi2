import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/auth_provider.dart';
import 'package:study_app/screens/splash_screen.dart';
import 'package:study_app/screens/auth/login_screen.dart';
import 'package:study_app/screens/home/main_screen.dart';
import 'package:study_app/services/notification_service.dart';

// Importações dos serviços
import 'package:study_app/services/storage_service.dart';
import 'package:study_app/services/api_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. INICIALIZAR HIVE PRIMEIRO (ESSENCIAL)
  await Hive.initFlutter();

  // 2. AGORA INICIALIZAR OS SERVIÇOS QUE DEPENDEM DO HIVE E DA REDE
  // O StorageService já abre as caixas 'settings' e 'cache' dentro dele
  await StorageService().initialize();
  ApiService().initialize();

  // 3. REMOVER CHAMADAS DUPLICADAS (já estão no StorageService)
  // await Hive.openBox('settings'); <-- REMOVIDO
  // await Hive.openBox('cache');    <-- REMOVIDO

  // 4. INICIALIZAR O RESTO
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

