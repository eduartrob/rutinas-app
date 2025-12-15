import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recovery_password_provider.dart';
import 'package:app/features/auth/login/presentation/widgets/auth_widgets.dart';
import 'verify_code_page.dart';

/// Forgot password page - Step 1
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VerifyCodePage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
                    color: const Color(0xFF252537),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
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
                        
                        // Title
                        const Text(
                          'Forgot Your\nPassword?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Text(
                          "No problem. Enter your email address and we'll send you a link to reset it.",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Email field
                        AuthTextField(
                          label: 'Email Address',
                          hintText: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Error message
                        Consumer<RecoveryPasswordProvider>(
                          builder: (context, provider, _) {
                            if (provider.errorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  provider.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Send reset link button
                        Consumer<RecoveryPasswordProvider>(
                          builder: (context, provider, _) {
                            return AuthPrimaryButton(
                              text: 'Send Reset Link',
                              isLoading: provider.isLoading,
                              onPressed: _onSendResetLink,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Back to login link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.read<RecoveryPasswordProvider>().reset();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: Color(0xFF64B5F6),
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
