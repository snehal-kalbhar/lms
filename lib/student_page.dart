
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final Color primaryColor = const Color(0xFF5B5FEF);
  final Color backgroundColor = const Color(0xFFF6F7FB);

  String searchText = '';

  // ============================================================
  // ENROLL COURSE
  // ============================================================

  Future<void> enrollCourse(String courseId) async {
    if (currentUser == null) return;

    final enrollmentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('enrolledCourses')
        .doc(courseId);

    final existingEnrollment = await enrollmentRef.get();

    if (existingEnrollment.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already enrolled in this course.'),
          ),
        );
      }

      return;
    }

    await enrollmentRef.set({
      'courseId': courseId,
      'enrolledAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course enrolled successfully! 🎉'),
        ),
      );
    }
  }

  // ============================================================
  // CHECK ENROLLMENT
  // ============================================================

  Stream<QuerySnapshot> get enrolledCoursesStream {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('enrolledCourses')
        .snapshots();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong.',
              ),
            );
          }

          final allCourses = snapshot.data?.docs ?? [];

          // Search filter
          final courses = allCourses.where((course) {
            final data =
                course.data() as Map<String, dynamic>;

            final title =
                (data['title'] ?? '').toString().toLowerCase();

            final category =
                (data['category'] ?? '').toString().toLowerCase();

            return title.contains(searchText.toLowerCase()) ||
                category.contains(searchText.toLowerCase());
          }).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: enrolledCoursesStream,

            builder: (context, enrolledSnapshot) {
              if (enrolledSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final enrolledDocs =
                  enrolledSnapshot.data?.docs ?? [];

              final enrolledIds =
                  enrolledDocs.map((doc) => doc.id).toSet();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // WELCOME BANNER
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            const Color(0xFF7C80F5),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(26),

                        boxShadow: [
                          BoxShadow(
                            color:
                                primaryColor.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          Container(
                            height: 60,
                            width: 60,

                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  'Welcome back! 👋',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  currentUser?.email ??
                                      'Student',

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // STATISTICS
                    // ==================================================

                    Row(
                      children: [

                        Expanded(
                          child: _statCard(
                            icon:
                                Icons.menu_book_rounded,
                            title: 'Available',
                            value:
                                allCourses.length.toString(),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _statCard(
                            icon:
                                Icons.bookmark_rounded,
                            title: 'My Courses',
                            value:
                                enrolledIds.length.toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // SEARCH BAR
                    // ==================================================

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(17),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },

                        decoration: InputDecoration(
                          hintText:
                              'Search courses...',

                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: primaryColor,
                          ),

                          suffixIcon:
                              searchText.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          searchText = '';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                      ),
                                    )
                                  : null,

                          border: InputBorder.none,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // MY COURSES
                    // ==================================================

                    const Text(
                      'My Courses',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (enrolledIds.isEmpty)
                      _emptyMyCourses()
                    else
                      ...enrolledIds.map((courseId) {
                        final matchingCourses =
                            allCourses.where(
                          (course) =>
                              course.id == courseId,
                        );

                        if (matchingCourses.isEmpty) {
                          return const SizedBox();
                        }

                        final course =
                            matchingCourses.first;

                        final data = course.data()
                            as Map<String, dynamic>;

                        return _myCourseCard(
                          title:
                              data['title'] ??
                                  'Untitled Course',
                          category:
                              data['category'] ??
                                  'General',
                        );
                      }),

                    const SizedBox(height: 30),

                    // ==================================================
                    // ALL COURSES
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          'Explore Courses',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          '${courses.length} courses',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // COURSE LIST
                    // ==================================================

                    if (courses.isEmpty)
                      _emptySearch()
                    else
                      ...courses.map((course) {
                        final data = course.data()
                            as Map<String, dynamic>;

                        final bool isEnrolled =
                            enrolledIds.contains(
                          course.id,
                        );

                        return _courseCard(
                          courseId: course.id,
                          title:
                              data['title'] ??
                                  'Untitled Course',
                          description:
                              data['description'] ??
                                  '',
                          category:
                              data['category'] ??
                                  'General',
                          isEnrolled: isEnrolled,
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 45,
            width: 45,

            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE CARD
  // ============================================================

  Widget _courseCard({
    required String courseId,
    required String title,
    required String description,
    required String category,
    required bool isEnrolled,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // Course icon
              Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  color:
                      primaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Icon(
                  Icons.play_lesson_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: primaryColor
                            .withOpacity(0.1),

                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        category,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            description,
            maxLines: 3,
            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 17),

          // Enroll button
          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: isEnrolled
                  ? null
                  : () {
                      enrollCourse(courseId);
                    },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                disabledBackgroundColor:
                    Colors.grey.shade200,

                disabledForegroundColor:
                    Colors.grey.shade600,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),

              icon: Icon(
                isEnrolled
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
              ),

              label: Text(
                isEnrolled
                    ? 'Already Enrolled'
                    : 'Enroll Now',

                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MY COURSE CARD
  // ============================================================

  Widget _myCourseCard({
    required String title,
    required String category,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.bookmark_rounded,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY MY COURSES
  // ============================================================

  Widget _emptyMyCourses() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Icon(
            Icons.bookmark_border_rounded,
            size: 45,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 10),

          const Text(
            'No enrolled courses',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Explore courses below and start learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY SEARCH
  // ============================================================

  Widget _emptySearch() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Icon(
            Icons.search_off_rounded,
            size: 50,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 10),

          const Text(
            'No courses found',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try searching for another course.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

