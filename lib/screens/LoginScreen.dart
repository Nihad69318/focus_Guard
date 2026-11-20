import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:focus_guard/screens/Home_Screen.dart';
import 'package:focus_guard/screens/SignupScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Firebase/Firebase_Service/AuthenticationServices.dart';
import '../utils/Utils.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationServices _services = AuthenticationServices();

  bool isPasswordVisible = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Create a profile if it does not exist.
  // Every user's profile is saved using their Firebase UID.
  Future<void> _ensureUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    final document = await userRef.get();

    if (!document.exists) {
      final fullName = user.displayName ?? '';
      final nameParts = fullName.trim().isEmpty
          ? <String>[]
          : fullName.trim().split(RegExp(r'\s+'));

      final firstName = nameParts.isNotEmpty ? nameParts.first : '';

      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      await userRef.set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Email and Password Login
  Future<void> _loginWithEmail() async {
    if (isLoading || isGoogleLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('User not found.');
      }

      // Ensure this user's Firestore profile exists.
      await _ensureUserProfile(user);

      if (!mounted) return;

      Utels.SuccessToset('Login Success');

      // Login successful: Go to Home Screen.
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email or password is incorrect.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      Utels.failToset(message);

      debugPrint('Email Login Error: ${e.code} - ${e.message}');
    } catch (e) {
      if (!mounted) return;

      Utels.failToset('Something went wrong. Please try again.');

      debugPrint('Email Login Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Google Login
  Future<void> _loginWithGoogle() async {
    if (isGoogleLoading || isLoading) return;

    setState(() {
      isGoogleLoading = true;
    });

    try {
      final User? user = await _services.googleWithSignin();

      if (user == null) return;

      // Ensure Google user's Firestore profile exists.
      await _ensureUserProfile(user);

      if (!mounted) return;

      Utels.SuccessToset('Google Login Success');

      // Google login successful: Go to Home Screen.
      // context.go('/home');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );


    } catch (e) {
      if (!mounted) return;

      debugPrint('Google Login Error: $e');

      Utels.failToset('Google Login Failed');
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  // Open Signup Screen
  void _openSignup() {
    if (isLoading || isGoogleLoading) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signupscreen()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/little-twins-playing-smartphone.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.70)),
          ),

          // Login Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Login to continue your focus journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 35),

                      // Email Field
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          if (!RegExp(
                            r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$',
                          ).hasMatch(value.trim())) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Password Field
                      TextFormField(
                        controller: password,
                        obscureText: !isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        onFieldSubmitted: (_) => _loginWithEmail(),
                        decoration: _inputDecoration(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Login Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading || isGoogleLoading
                              ? null
                              : _loginWithEmail,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // OR Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white38)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white38)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google Login
                      InkWell(
                        onTap: isLoading || isGoogleLoading
                            ? null
                            : _loginWithGoogle,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/search.png',
                                width: 25,
                                height: 25,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isGoogleLoading
                                    ? 'Connecting...'
                                    : 'Continue with Google',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Facebook Login
                      InkWell(
                        onTap: () {
                          if (isLoading || isGoogleLoading) return;

                          Utels.failToset(
                            'Facebook Login is not configured yet.',
                          );
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.facebook,
                                size: 25,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Continue with Facebook',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Signup Navigation
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openSignup,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Input Decoration
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 1.5),
      ),
    );
  }
}
