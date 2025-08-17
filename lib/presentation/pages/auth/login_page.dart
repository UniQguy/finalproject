import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _borderPulse;

  @override
  void initState() {
    super.initState();

    // Animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ));

    _borderPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    // repeat for continuous border animation
    _controller.repeat(reverse: true, period: const Duration(seconds: 3));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_email.text, _password.text);
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .signInWithGoogle();
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Colors for background gradient stages
  static const List<List<Color>> gradientStages = [
    [Color(0xFF16161C), Color(0xFF23234A)],
    [Color(0xFF23234A), Color(0xFF2D1938)],
    [Color(0xFF2D1938), Color(0xFF23234A)],
    [Color(0xFF23234A), Color(0xFF16161C)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, _) {
          // Animate between gradient color stages
          final steps = gradientStages.length;
          final pos = _controller.value * (steps - 1);
          final idx = pos.floor();
          final nextIdx = (idx + 1) % steps;
          final t = pos - idx;
          final colorA = Color.lerp(
            gradientStages[idx][0],
            gradientStages[nextIdx][0],
            t,
          )!;
          final colorB = Color.lerp(
            gradientStages[idx][1],
            gradientStages[nextIdx][1],
            t,
          )!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorA, colorB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    child: AnimatedBuilder(
                      animation: _borderPulse,
                      builder: (ctx, _) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purpleAccent
                                  .withOpacity(_borderPulse.value),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated Logo scale and fade
                              ScaleTransition(
                                scale: Tween<double>(begin: 0.97, end: 1.04)
                                    .animate(CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.easeInOutSine,
                                )),
                                child: Image.asset(
                                  'lib/assets/images/logo_.png',
                                  height: 74,
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimatedBuilder(
                                animation: _fadeAnim,
                                builder: (context, _) => Opacity(
                                  opacity: _fadeAnim.value,
                                  child: Text(
                                    'DemoTrader',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent
                                          .withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _email,
                                      label: "Email",
                                      icon: Icons.email_outlined,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Please enter email';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                            .hasMatch(v)) {
                                          return 'Invalid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _password,
                                      label: "Password",
                                      icon: Icons.lock_outline,
                                      obscure: _obscure,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.purpleAccent
                                              .withOpacity(0.8),
                                        ),
                                        onPressed: () => setState(
                                                () => _obscure = !_obscure),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Please enter password';
                                        }
                                        if (v.length < 6) {
                                          return 'Min 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    _buildAnimatedButton(
                                      onTap: _isLoading ? null : _submit,
                                      loading: _isLoading,
                                      text: "Log In",
                                    ),
                                    const SizedBox(height: 14),
                                    _buildGoogleButton(),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Don't have an account?",
                                          style: TextStyle(
                                              color: Colors.white70),
                                        ),
                                        TextButton(
                                          onPressed: () => context
                                              .go(AppRoutes.signup),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: Colors.purpleAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffix,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOut,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.purpleAccent.shade200),
          prefixIcon: Icon(icon, color: Colors.purpleAccent.shade200),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.grey.shade800.withOpacity(0.7),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.purpleAccent.shade200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.purpleAccent.shade200.withOpacity(0.5),
                width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback? onTap,
    required bool loading,
    required String text,
  }) {
    return AnimatedScale(
      scale: loading ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent.shade200,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 5,
          ),
          onPressed: onTap,
          child: loading
              ? const CircularProgressIndicator(color: Colors.black87)
              : Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return AnimatedOpacity(
      opacity: _isGoogleLoading ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 240),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.purpleAccent.shade200),
            foregroundColor: Colors.purpleAccent.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _isGoogleLoading ? null : _signInWithGoogle,
          icon: _isGoogleLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.purpleAccent,
            ),
          )
              : Image.asset(
            'lib/assets/images/google_logo.png',
            height: 20,
          ),
          label: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
