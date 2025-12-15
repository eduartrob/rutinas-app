import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/recovery_password_provider.dart';
import 'package:app/features/auth/login/presentation/widgets/auth_widgets.dart';
import 'package:app/core/router/routes.dart';
import 'verify_code_page.dart';

/// Página de recuperación de contraseña - Paso 1
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<RecoveryPasswordProvider>();
      final success = await provider.forgotPassword(
        email: _emailController.text.trim(),
      );
      
      if (success && mounted) {
        context.push(AppRoutes.verifyCodePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        const Center(child: AuthLogo(filled: false, size: 60)),
                        const SizedBox(height: 24),
                        
                        // Título
                        Text(
                          '¿Olvidaste tu\ncontraseña?',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Subtítulo
                        Text(
                          'No te preocupes. Ingresa tu correo electrónico y te enviaremos un código para restablecerla.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Campo de email
                        AuthTextField(
                          label: 'Correo electrónico',
                          hintText: 'tu@correo.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Mensaje de error
                        Consumer<RecoveryPasswordProvider>(
                          builder: (context, provider, _) {
                            if (provider.errorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón de enviar
                        Consumer<RecoveryPasswordProvider>(
                          builder: (context, provider, _) {
                            return AuthPrimaryButton(
                              text: 'Enviar Código',
                              isLoading: provider.isLoading,
                              onPressed: _onSendResetLink,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Volver al login
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.read<RecoveryPasswordProvider>().reset();
                              context.pop();
                            },
                            child: Text(
                              'Volver al inicio de sesión',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
