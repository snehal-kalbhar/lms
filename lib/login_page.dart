
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/register_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFF5B5FEF);

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // AuthWrapper will automatically detect
      // the logged-in user and redirect according to role.

    } on FirebaseAuthException catch (e) {

      String message = 'Something went wrong.';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      }

      else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }

      else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }

      else if (e.code == 'too-many-requests') {
        message =
            'Too many attempts. Please try again later.';
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                vertical: 30,
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
                      height: 85,
                      width: 85,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.school_rounded,
                        size: 45,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // APP NAME
                    // ==================================================

                    const Text(
                      'CODE GURUCOOL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Not just code we build character',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ==================================================
                    // LOGIN CARD
                    // ==================================================

                    Container(

                      padding: const EdgeInsets.all(26),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.15),
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

                            // ==================================================
                            // TITLE
                            // ==================================================

                            const Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'Login to continue your learning journey.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ==================================================
                            // EMAIL
                            // ==================================================

                            const Text(
                              'Email Address',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(

                              controller: emailController,

                              keyboardType:
                                  TextInputType.emailAddress,

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Enter your email',

                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: primaryColor,
                                ),

                                filled: true,

                                fillColor:
                                    const Color(0xFFF7F7FA),

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide.none,
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide.none,
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
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

                            const SizedBox(height: 18),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            const Text(
                              'Password',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(

                              controller:
                                  passwordController,

                              obscureText:
                                  !isPasswordVisible,

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Enter your password',

                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: primaryColor,
                                ),

                                suffixIcon:
                                    IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible =
                                          !isPasswordVisible;
                                    });
                                  },

                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons
                                            .visibility_rounded
                                        : Icons
                                            .visibility_off_rounded,
                                    color: Colors.grey,
                                  ),
                                ),

                                filled: true,

                                fillColor:
                                    const Color(0xFFF7F7FA),

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide.none,
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide.none,
                                ),

                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                  borderSide:
                                      BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              validator: (value) {

                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Please enter your password';
                                }

                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // LOGIN BUTTON
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: ElevatedButton(

                                onPressed:
                                    isLoading
                                        ? null
                                        : login,

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      primaryColor,

                                  foregroundColor:
                                      Colors.white,

                                  disabledBackgroundColor:
                                      primaryColor
                                          .withOpacity(
                                              0.6),

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            15),
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
                                            MainAxisAlignment
                                                .center,

                                        children: [

                                          Text(
                                            'Login',
                                            style:
                                                TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
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

                            const SizedBox(height: 25),

                            // ==================================================
                            // SIGN UP
                            // ==================================================

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                GestureDetector(

                                  onTap: () {

                                    Navigator.push(
                                      context,

                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const RegisterPage(),
                                      ),
                                    );
                                  },

                                  child: Text(
                                    'Sign Up',
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

                    const SizedBox(height: 25),

                    // ==================================================
                    // FOOTER
                    // ==================================================

                    const Text(
                      '© 2026 Code_Gurucool • LMS',
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
}

