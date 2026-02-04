/// Flutter script to upload course and admin data to Firestore
/// Run with: flutter run lib/upload_data_script.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const DataUploadApp());
}

class DataUploadApp extends StatelessWidget {
  const DataUploadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DataUploadScreen(),
    );
  }
}

class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({Key? key}) : super(key: key);

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  String status = 'Ready to upload';
  bool uploading = false;

  Future<void> uploadAllData() async {
    setState(() {
      uploading = true;
      status = 'Starting upload...';
    });

    try {
      // Upload course
      setState(() => status = 'Uploading course data...');
      await uploadCourseData();

      // Upload admin user
      setState(() => status = 'Uploading admin user...');
      await uploadAdminUser();

      setState(() {
        uploading = false;
        status = '✅ SUCCESS! All data uploaded to Firestore';
      });
    } catch (e) {
      setState(() {
        uploading = false;
        status = '❌ Error: $e';
      });
    }
  }

  Future<void> uploadCourseData() async {
    final firestore = FirebaseFirestore.instance;

    final courseData = {
      'name': 'Tai Chi Fundamentals',
      'description':
          'Complete Tai Chi training course covering structure, flexibility, fluidity, and power. Master the ancient art of Tai Chi through systematic instruction and practice.',
      'isActive': true,
      'isDefault': true,
      'isFree': false,
      'order': 1,
      'thumbnailUrl': '',
      'sections': getCourseData(),
      'metadata': {
        'totalVideos': 22,
        'totalSections': 6,
        'totalDuration': 7200,
        'premiumVideos': 0,
        'freeVideos': 22,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('courses').doc('tai_chi_fundamentals').set(courseData);
  }

  Future<void> uploadAdminUser() async {
    final firestore = FirebaseFirestore.instance;

    final userData = {
      'username': 'admin',
      'password': 'simple_hash_workout2026',
      'role': 'admin',
      'email': 'admin@amazingelearning.com',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': null,
    };

    await firestore.collection('users').doc('admin_user').set(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Data to Firestore'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              if (uploading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: uploadAllData,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Upload All Data'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> getCourseData() {
  return [
    {
      'sectionNumber': 1,
      'title': 'About Us',
      'description': 'Introduction to our Tai Chi program',
      'order': 1,
      'videos': [
        {
          'row': 1,
          'title': 'About us',
          'description':
              'Learn about our Tai Chi program and the philosophy behind our teaching approach.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_1_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 300,
          'tags': ['introduction', 'about'],
        }
      ]
    },
    {
      'sectionNumber': 2,
      'title': 'Intro by John Saxxon',
      'description': 'Introduction and course outline',
      'order': 2,
      'videos': [
        {
          'row': 1,
          'title': 'Intro by John Saxxon',
          'description':
              'The ancient art of Tai Chiwan is based upon the principle of relaxing the body...',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_2_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 420,
          'tags': ['introduction'],
        },
        {
          'row': 2,
          'title': 'Course Outline',
          'description': 'Overview of the complete course structure',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_2_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 360,
          'tags': ['outline'],
        }
      ]
    },
    // ... continuing with all sections
  ];
}
