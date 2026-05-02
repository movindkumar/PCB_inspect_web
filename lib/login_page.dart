import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  static const String _operatorUsername = 'operator';
  static const String _operatorPassword = '123';
  static const String _engineerUsername = 'engineer';
  static const String _engineerPassword = 'eng123';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

 void _handleLogin() {
    setState(() => _errorMessage = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both username and password.');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final isOperator =
          username == _operatorUsername && password == _operatorPassword;
      final isEngineer =
          username == _engineerUsername && password == _engineerPassword;

      if (isOperator || isEngineer) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(
              username: username,
              role: isOperator ? 'operator' : 'engineer',
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid operator ID or password.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D14),
      body: Row(
        children: [
          // Left Panel - Branding
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A1628),
                border: Border(
                  right: BorderSide(color: Color(0xFF1A2F4A), width: 1),
                ),
              ),
              child: Stack(
                children: [
                  // Grid pattern background
                  CustomPaint(
                    painter: _GridPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C2A8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.developer_board,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'PCB Inspect Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Main heading
                        const Text(
                          'Automated\nOptical\nInspection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 48,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C2A8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'AI-powered PCB defect detection and\nclassification system for quality control\noperators.',
                          style: TextStyle(
                            color: Color(0xFF6A8BAD),
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Feature chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _FeatureChip(
                                icon: Icons.search,
                                label: 'Defect Detection'),
                            _FeatureChip(
                                icon: Icons.category_outlined,
                                label: 'Classification'),
                            _FeatureChip(
                                icon: Icons.analytics_outlined,
                                label: 'AOI Analysis'),
                            _FeatureChip(
                                icon: Icons.cloud_done_outlined,
                                label: 'Cloud Logging'),
                          ],
                        ),

                        const Spacer(),

                        // Bottom status bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1F35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF1A3A5C), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C2A8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'System Online  •  AOI Engine Ready',
                                style: TextStyle(
                                  color: Color(0xFF6A8BAD),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'v1.0.0  •  PCB Inspect Pro',
                          style: TextStyle(
                            color: Color(0xFF2E4A66),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Panel - Login Form
          Expanded(
            flex: 4,
            child: FadeTransition(
              opacity: _fadeController,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C2A8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF00C2A8).withOpacity(0.3),
                                width: 1),
                          ),
                          child: const Text(
                            'OPERATOR ACCESS',
                            style: TextStyle(
                              color: Color(0xFF00C2A8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your credentials to access the\ninspection dashboard.',
                          style: TextStyle(
                            color: Color(0xFF6A8BAD),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Operator ID Field
                        _buildLabel('Operator ID'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Enter your operator ID',
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF4A6A8A),
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D0A0A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF6B1A1A), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFFF6B6B), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B6B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C2A8),
                              disabledBackgroundColor:
                                  const Color(0xFF00C2A8).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Access Dashboard',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward,
                                          color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0xFF1A2F4A),
                        ),

                        const SizedBox(height: 20),

                        // Bottom info
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                color: Color(0xFF2E4A66), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Authorized personnel only.\nUnauthorized access is prohibited.',
                              style: TextStyle(
                                color: Color(0xFF3A5A7A),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8AAAC8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: const Color(0xFF00C2A8),
      onSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF3A5A7A), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6A8A), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0D1F35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A3A5C), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A3A5C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF00C2A8), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// Feature chip widget
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1A3A5C), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00C2A8), size: 14),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6A8BAD),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Grid background painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F2035)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}