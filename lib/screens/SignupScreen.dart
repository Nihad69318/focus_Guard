import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:focus_guard/screens/LoginScreen.dart';
import 'package:go_router/go_router.dart';
import '../app/color/app_colors.dart';
import '../utils/Utils.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPasswordVisible = false;
  bool isLoading = false;

  bool isNavigating = false;

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Firebase Registration
  Future<void> register() async {
    // Prevent repeated clicks
    if (isLoading || isNavigating) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Create Firebase Auth Account
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text,
          );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('User account could not be created.');
      }

      // 2. Update Display Name
      final String fullName =
          '${firstname.text.trim()} ${lastname.text.trim()}';

      await user.updateDisplayName(fullName);

      // 3. Save User Information in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': firstname.text.trim(),
        'lastName': lastname.text.trim(),
        'fullName': fullName,
        'email': email.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 4. Lock navigation
      setState(() {
        isNavigating = true;
      });

      // 5. Sign Out
      await _auth.signOut();

      if (!mounted) return;

      // 6. Show Success Message
      Utels.SuccessToset('Registration Successful');

      // 7. Navigate only once
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginscreen()));

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          message = 'Email/Password registration is not enabled.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      Utels.failToset(message);

      debugPrint('Registration Error: ${e.code} - ${e.message}');
    } catch (e) {
      if (!mounted) return;

      Utels.failToset('Registration failed. Please try again.');

      debugPrint('Registration Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Input Decoration
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBorder,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Start your focus journey with us',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // First Name
                  TextFormField(
                    controller: firstname,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }

                      if (value.trim().length < 2) {
                        return 'First name must be at least 2 characters';
                      }

                      if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
                        return 'Please enter a valid first name';
                      }

                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'First name',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Last Name
                  TextFormField(
                    controller: lastname,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }

                      if (value.trim().length < 2) {
                        return 'Last name must be at least 2 characters';
                      }

                      if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
                        return 'Please enter a valid last name';
                      }

                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'Last name',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email
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

                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: password,
                    obscureText: !isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
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
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Register Button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isLoading || isNavigating) ? null : register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.secondary.withValues(
                          alpha: 0.5,
                        ),
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
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Navigation
                  RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
