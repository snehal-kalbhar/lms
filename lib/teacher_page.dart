
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final Color primaryColor = const Color(0xFF5B5FEF);
  final Color backgroundColor = const Color(0xFFF6F7FB);

  // ------------------------------------------------------------
  // ADD / EDIT COURSE DIALOG
  // ------------------------------------------------------------

  void showCourseDialog({
    String? courseId,
    String? oldTitle,
    String? oldDescription,
    String? oldCategory,
  }) {
    final titleController = TextEditingController(text: oldTitle ?? '');
    final descriptionController =
        TextEditingController(text: oldDescription ?? '');
    final categoryController =
        TextEditingController(text: oldCategory ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            courseId == null ? 'Add New Course' : 'Edit Course',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Course title
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Course Title',
                    prefixIcon: const Icon(Icons.menu_book_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Category
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {

                if (titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  return;
                }

                if (courseId == null) {

                  // ADD COURSE
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .add({
                    'title': titleController.text.trim(),
                    'description':
                        descriptionController.text.trim(),
                    'category':
                        categoryController.text.trim(),
                    'teacherId': currentUser!.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                } else {

                  // EDIT COURSE
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
                      .update({
                    'title': titleController.text.trim(),
                    'description':
                        descriptionController.text.trim(),
                    'category':
                        categoryController.text.trim(),
                  });
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                courseId == null ? 'Add Course' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DELETE COURSE
  // ------------------------------------------------------------

  void deleteCourse(String courseId, String title) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Delete Course?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "$title"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 168, 152, 249),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {

                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .delete();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        title: const Text(
          'Teacher Dashboard',
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

      // --------------------------------------------------------
      // BODY
      // --------------------------------------------------------

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where(
              'teacherId',
              isEqualTo: currentUser?.uid,
            )
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

          final courses = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ------------------------------------------------
                // WELCOME SECTION
                // ------------------------------------------------

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

                    borderRadius: BorderRadius.circular(26),

                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      // Icon
                      Container(
                        height: 60,
                        width: 60,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Text
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
                              currentUser?.email ?? 'Teacher',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ------------------------------------------------
                // STATISTICS
                // ------------------------------------------------

                Row(
                  children: [

                    Expanded(
                      child: _statCard(
                        icon: Icons.menu_book_rounded,
                        title: 'My Courses',
                        value: courses.length.toString(),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: _statCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Students',
                        value: '0',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // COURSE HEADER
                // ------------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(
                      'My Courses',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    ElevatedButton.icon(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,

                        elevation: 0,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),

                      onPressed: () {
                        showCourseDialog();
                      },

                      icon: const Icon(
                        Icons.add_rounded,
                        size: 20,
                      ),

                      label: const Text(
                        'Add Course',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // EMPTY STATE
                // ------------------------------------------------

                if (courses.isEmpty)

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(35),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),

                    child: Column(
                      children: [

                        Icon(
                          Icons.menu_book_outlined,
                          size: 60,
                          color: primaryColor,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'No courses yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Create your first course and start teaching.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () {
                            showCourseDialog();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),

                          icon: const Icon(Icons.add),

                          label: const Text(
                            'Create Course',
                          ),
                        ),
                      ],
                    ),
                  ),

                // ------------------------------------------------
                // COURSE LIST
                // ------------------------------------------------

                ...courses.map((course) {

                  final data =
                      course.data() as Map<String, dynamic>;

                  return _courseCard(
                    courseId: course.id,
                    title: data['title'] ?? 'Untitled Course',
                    description:
                        data['description'] ?? '',
                    category:
                        data['category'] ?? 'General',
                  );
                }),
              ],
            ),
          );
        },
      ),

      // ----------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------

      floatingActionButton: FloatingActionButton.extended(

        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        onPressed: () {
          showCourseDialog();
        },

        icon: const Icon(Icons.add_rounded),

        label: const Text(
          'New Course',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
              borderRadius: BorderRadius.circular(13),
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
                  overflow: TextOverflow.ellipsis,

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
                    fontWeight: FontWeight.bold,
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
  }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: primaryColor.withOpacity(0.1),
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

              // Course title
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color:
                            primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        category,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // More menu
              PopupMenuButton<String>(

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                onSelected: (value) {

                  if (value == 'edit') {

                    showCourseDialog(
                      courseId: courseId,
                      oldTitle: title,
                      oldDescription: description,
                      oldCategory: category,
                    );

                  } else if (value == 'delete') {

                    deleteCourse(
                      courseId,
                      title,
                    );
                  }
                },

                itemBuilder: (context) => [

                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),

                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Description
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Bottom buttons
          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(

                  onPressed: () {
                    showCourseDialog(
                      courseId: courseId,
                      oldTitle: title,
                      oldDescription: description,
                      oldCategory: category,
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,

                    side: BorderSide(
                      color: primaryColor
                          .withOpacity(0.3),
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),

                  label: const Text('Edit'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(

                  onPressed: () {
                    deleteCourse(
                      courseId,
                      title,
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.redAccent,

                    side: BorderSide(
                      color: Colors.redAccent
                          .withOpacity(0.3),
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                  ),

                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
