import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_app/constants/app_theme.dart';
import 'package:study_app/providers/auth_provider.dart';
import 'package:study_app/services/auth_service.dart';
import 'package:study_app/widgets/custom_button.dart';
import 'package:study_app/widgets/custom_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você deve aceitar os termos de uso'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Faça login para continuar.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ADICIONE ESTAS LINHAS AQUI PARA VER O ERRO REAL
      print('--- ERRO DETALHADO NO FLUTTER AO TENTAR REGISTRAR ---');
      print(e);
      print('----------------------------------------------------');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()), // Isso mostra a mensagem genérica
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Preencha os dados abaixo para criar sua conta',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campo de nome
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome completo',
                  hint: 'Digite seu nome completo',
                  prefixIcon: Icons.person_outlined,
                  validator: AuthService.validateName,
                ),
                
                const SizedBox(height: 16),
                
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
                  validator: AuthService.validatePassword,
                ),
                
                const SizedBox(height: 16),
                
                // Campo de confirmação de senha
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  hint: 'Digite sua senha novamente',
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: _validateConfirmPassword,
                ),
                
                const SizedBox(height: 24),
                
                // Checkbox de termos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              children: [
                                TextSpan(text: 'Eu aceito os '),
                                TextSpan(
                                  text: 'Termos de Uso',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: ' e a '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botão de registro
                CustomButton(
                  text: 'Criar conta',
                  onPressed: _isLoading ? null : _handleRegister,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Fazer login',
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

