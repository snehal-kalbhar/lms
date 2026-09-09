import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'student_page.dart';
import 'teacher_page.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, authSnapshot) {
        // Loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is not logged in
        if (!authSnapshot.hasData) {
          return LoginPage();
        }

        final User user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            // Loading user data
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // User document not found
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'User profile not found.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>;

            final String role = data['role'] ?? '';

            // Student
            if (role == 'student') {
              return  StudentPage();
            }

            // Teacher
            if (role == 'teacher') {
              return TeacherPage();
            }

            // Invalid role
            return const Scaffold(
              body: Center(
                child: Text(
                  'Invalid user role.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          },
        );
      },
    );
  }
}