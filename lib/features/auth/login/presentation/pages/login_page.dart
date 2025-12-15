import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../widgets/auth_widgets.dart';
import 'package:app/core/router/routes.dart';

/// Página de inicio de sesión con tema oscuro
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
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
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<LoginProvider>();
      final success = await provider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido ${provider.user?.name}!'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        context.go(AppRoutes.homePath);
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
                      children: [
                        // Logo
                        const AuthLogo(filled: true, size: 60),
                        const SizedBox(height: 24),
                        
                        // Título
                        Text(
                          'Bienvenido',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Campo de email
                        AuthTextField(
                          label: 'Correo electrónico',
                          hintText: 'Ingresa tu correo',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Contraseña con link de olvidé
                        Consumer<LoginProvider>(
                          builder: (context, provider, _) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Contraseña',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.push(AppRoutes.forgotPasswordPath),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                      ),
                                      child: Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: provider.obscurePassword,
                                  style: TextStyle(color: colorScheme.onSurface),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Ingresa tu contraseña',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        provider.obscurePassword 
                                            ? Icons.visibility_off 
                                            : Icons.visibility,
                                        color: colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      onPressed: provider.togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Mensaje de error
                        Consumer<LoginProvider>(
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
                        
                        // Botón de iniciar sesión
                        Consumer<LoginProvider>(
                          builder: (context, provider, _) {
                            return AuthPrimaryButton(
                              text: 'Iniciar Sesión',
                              isLoading: provider.isLoading,
                              onPressed: _onLogin,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Link de registro
                        AuthLinkButton(
                          text: '¿No tienes cuenta?',
                          linkText: 'Regístrate',
                          onPressed: () => context.push(AppRoutes.registerPath),
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
