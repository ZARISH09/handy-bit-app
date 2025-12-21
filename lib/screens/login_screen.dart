import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_bit/screens/home_screen.dart';
import 'package:handy_bit/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  final RegExp _emailRegex =
  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // -------------------- LOGIN FUNCTION --------------------------
  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog("Welcome back!", () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (_) {
      _showErrorDialog("Network error. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // -------------------- ERROR HANDLING --------------------------
  void _handleFirebaseError(FirebaseAuthException e) {
    String errorMessage = '';
    String? emailError;
    String? passwordError;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email.';
        emailError = 'Account not found';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        passwordError = 'Wrong password';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email format.';
        emailError = 'Invalid email';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again later.';
        break;
      case 'network-request-failed':
        errorMessage = 'Check your internet connection.';
        break;
      default:
        errorMessage = 'Login failed. Please try again.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    _showErrorDialog(errorMessage);
  }

  // -------------------- VALIDATORS --------------------------
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    if (!_emailRegex.hasMatch(value.trim())) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  // -------------------- DIALOGS --------------------------
  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String msg, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: onOk,
            child: const Text("CONTINUE", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // -------------------- RESET PASSWORD --------------------------
  void _resetPassword() {
    if (_emailController.text.isEmpty ||
        !_emailRegex.hasMatch(_emailController.text)) {
      _showErrorDialog("Enter a valid email to reset password.");
      return;
    }

    FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim());

    _showSuccessDialog(
      "Reset link sent to your email!",
          () => Navigator.pop(context),
    );
  }

  // -------------------- UI --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // App Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B5BDB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.home_repair_service,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "HandyBit",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B5BDB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Login to continue",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 32),
                // Email
                const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Remember + Forgot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                          activeColor: const Color(0xFF3B5BDB),
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: _resetPassword,
                      child: const Text("Forgot Password?"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Log In",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                // Or Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 26),
                // Google + Apple
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Text("G",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        label: const Text("Google"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.apple),
                        label: const Text("Apple"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Sign Up Link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),

                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade700),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
