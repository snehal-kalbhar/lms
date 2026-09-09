
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  String selectedRole = 'student';

  final Color primaryColor = const Color(0xFF5B5FEF);
  final Color backgroundColor = const Color(0xFFF6F7FB);

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create Firebase Authentication account
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;

      // Store user information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optional: update Firebase Auth display name
      await userCredential.user!.updateDisplayName(
        nameController.text.trim(),
      );

      if (!mounted) return;

      // Sign out so the user can login normally.
      // AuthWrapper will then show LoginPage.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully! Please login.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed.';

      if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'network-request-failed') {
        message = 'Please check your internet connection.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      filled: true,
      fillColor: const Color(0xFFF7F7FA),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              const Color(0xFF5B5FEF)
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 25,
              ),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),

                child: Column(
                  children: [

                    // ==================================================
                    // LOGO
                    // ==================================================

                    Container(
                      height: 75,
                      width: 75,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'LearnHub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Create your learning account',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // REGISTER CARD
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.all(26),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Form(
                        key: _formKey,

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Join LearnHub and start your journey.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // NAME
                            // ==================================================

                            const Text(
                              'Full Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: nameController,

                              textCapitalization:
                                  TextCapitalization.words,

                              decoration: inputDecoration(
                                hintText: 'Enter your full name',
                                icon: Icons.person_outline_rounded,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }

                                if (value.trim().length < 3) {
                                  return 'Name must be at least 3 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 17),

                            // ==================================================
                            // EMAIL
                            // ==================================================

                            const Text(
                              'Email Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: emailController,

                              keyboardType:
                                  TextInputType.emailAddress,

                              decoration: inputDecoration(
                                hintText: 'Enter your email',
                                icon: Icons.email_outlined,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }

                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 17),

                            // ==================================================
                            // ROLE
                            // ==================================================

                            const Text(
                              'Register As',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                Expanded(
                                  child: _roleCard(
                                    role: 'student',
                                    title: 'Student',
                                    icon: Icons.school_rounded,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: _roleCard(
                                    role: 'teacher',
                                    title: 'Teacher',
                                    icon: Icons.cast_for_education_rounded,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 17),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            const Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: passwordController,

                              obscureText:
                                  !isPasswordVisible,

                              decoration:
                                  inputDecoration(
                                hintText: 'Create a password',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible =
                                          !isPasswordVisible;
                                    });
                                  },

                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please enter a password';
                                }

                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 17),

                            // ==================================================
                            // CONFIRM PASSWORD
                            // ==================================================

                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller:
                                  confirmPasswordController,

                              obscureText:
                                  !isConfirmPasswordVisible,

                              decoration:
                                  inputDecoration(
                                hintText:
                                    'Confirm your password',
                                icon: Icons.lock_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isConfirmPasswordVisible =
                                          !isConfirmPasswordVisible;
                                    });
                                  },

                                  icon: Icon(
                                    isConfirmPasswordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please confirm your password';
                                }

                                if (value !=
                                    passwordController.text) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // REGISTER BUTTON
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : registerUser,

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      primaryColor,

                                  foregroundColor:
                                      Colors.white,

                                  disabledBackgroundColor:
                                      primaryColor
                                          .withOpacity(0.6),

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(15),
                                  ),
                                ),

                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,

                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        children: [

                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(width: 8),

                                          Icon(
                                            Icons
                                                .arrow_forward_rounded,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ==================================================
                            // LOGIN LINK
                            // ==================================================

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage(),
                                      ),
                                    );
                                  },

                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      '© 2026 LearnHub • LMS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _roleCard({
    required String role,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.08)
              : const Color(0xFFF7F7FA),

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.transparent,

            width: 1.5,
          ),
        ),

        child: Column(
          children: [

            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : Colors.grey,
              size: 28,
            ),

            const SizedBox(height: 7),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? primaryColor
                    : Colors.grey.shade700,

                fontWeight:
                    isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
