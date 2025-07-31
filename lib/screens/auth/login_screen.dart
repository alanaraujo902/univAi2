import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/auth_provider.dart';
import 'package:study_app/screens/auth/register_screen.dart';
import 'package:study_app/services/auth_service.dart';
import 'package:study_app/widgets/custom_button.dart';
import 'package:study_app/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Apenas chama o método do provider. O provider vai gerenciar o estado.
    // A UI vai reagir automaticamente quando o estado mudar em `main.dart`.
    await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo e título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Entre na sua conta para continuar estudando',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Campo de email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Digite seu email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AuthService.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Campo de senha
                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  obscureText: !_isPasswordVisible,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite sua senha';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Botão de login
                CustomButton(
                  text: 'Entrar',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Link "Esqueci minha senha"
                TextButton(
                  onPressed: () {
                    // TODO: Implementar recuperação de senha
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Divisor
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Link para registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToRegister,
                      child: const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

