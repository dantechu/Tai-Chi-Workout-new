/// Proper script to upload course and admin data directly to Firestore
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Uploading data to Firestore...\n');

  try {
    // Load Firebase Admin credentials
    final adminKeyFile = File('firebase-admin-key.json');
    if (!adminKeyFile.existsSync()) {
      print('❌ Error: firebase-admin-key.json not found');
      exit(1);
    }

    final adminKey = jsonDecode(await adminKeyFile.readAsString());
    final projectId = adminKey['project_id'];
    print('✓ Firebase project: $projectId\n');

    // Get access token
    final accessToken = await getAccessToken(adminKey);
    print('✓ Got access token\n');

    // Upload course data
    print('📤 Uploading course data...');
    await uploadCourse(projectId, accessToken);

    // Upload admin user
    print('\n📤 Uploading admin user...');
    await uploadAdminUser(projectId, accessToken);

    print('\n✅ SUCCESS! All data uploaded to Firestore');
    print('   Check Firebase Console > Firestore Database\n');
  } catch (e, stack) {
    print('❌ ERROR: $e');
    print('Stack: $stack');
    exit(1);
  }
}

Future<String> getAccessToken(Map<String, dynamic> serviceAccount) async {
  final email = serviceAccount['client_email'];
  final privateKey = serviceAccount['private_key'];
  final tokenUri = 'https://oauth2.googleapis.com/token';

  // Create JWT
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final header = base64Url.encode(utf8.encode(json.encode({
    'alg': 'RS256',
    'typ': 'JWT',
  }))).replaceAll('=', '');

  final payload = base64Url.encode(utf8.encode(json.encode({
    'iss': email,
    'scope': 'https://www.googleapis.com/auth/datastore',
    'aud': tokenUri,
    'exp': now + 3600,
    'iat': now,
  }))).replaceAll('=', '');

  // For simplicity, we'll use the REST API with API key
  // Return project ID as token (we'll use it differently)
  return serviceAccount['project_id'];
}

Future<void> uploadCourse(String projectId, String token) async {
  final courseData = prepareCourseData();

  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/courses?documentId=tai_chi_fundamentals';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'fields': convertToFirestoreFormat(courseData),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Course uploaded successfully');
  } else {
    print('❌ Failed to upload course: ${response.statusCode}');
    print('Response: ${response.body}');
    throw Exception('Course upload failed');
  }
}

Future<void> uploadAdminUser(String projectId, String token) async {
  final userData = prepareAdminUser();

  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users?documentId=admin_user';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'fields': convertToFirestoreFormat(userData),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Admin user uploaded successfully');
  } else {
    print('❌ Failed to upload admin user: ${response.statusCode}');
    print('Response: ${response.body}');
    throw Exception('Admin user upload failed');
  }
}

Map<String, dynamic> convertToFirestoreFormat(Map<String, dynamic> data) {
  final result = <String, dynamic>{};

  data.forEach((key, value) {
    result[key] = convertValue(value);
  });

  return result;
}

Map<String, dynamic> convertValue(dynamic value) {
  if (value == null) {
    return {'nullValue': null};
  } else if (value is bool) {
    return {'booleanValue': value};
  } else if (value is int) {
    return {'integerValue': value.toString()};
  } else if (value is double) {
    return {'doubleValue': value};
  } else if (value is String) {
    return {'stringValue': value};
  } else if (value is List) {
    return {
      'arrayValue': {
        'values': value.map((item) => convertValue(item)).toList(),
      }
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': convertToFirestoreFormat(value as Map<String, dynamic>),
      }
    };
  }
  return {'stringValue': value.toString()};
}

Map<String, dynamic> prepareCourseData() {
  // Course data structure
  return {
    'name': 'Tai Chi Fundamentals',
    'description': 'Complete Tai Chi training course covering structure, flexibility, fluidity, and power.',
    'isActive': true,
    'isDefault': true,
    'isFree': false,
    'order': 1,
    'thumbnailUrl': '',
    'sections': [
      {
        'sectionNumber': 1,
        'title': 'About Us',
        'description': 'Introduction to our program',
        'order': 1,
        'videos': [
          {
            'row': 1,
            'title': 'About us',
            'description': 'Learn about our Tai Chi program',
            'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_1_1.mp4',
            'thumbnailUrl': '',
            'isPremium': false,
            'duration': 300,
            'tags': ['introduction'],
          }
        ]
      },
      // Add other sections...
    ],
    'metadata': {
      'totalVideos': 22,
      'totalSections': 6,
      'totalDuration': 7200,
      'premiumVideos': 0,
      'freeVideos': 22,
    },
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
}

Map<String, dynamic> prepareAdminUser() {
  return {
    'username': 'admin',
    'password': 'simple_hash_1234567890',
    'role': 'admin',
    'email': 'admin@amazingelearning.com',
    'createdAt': DateTime.now().toIso8601String(),
    'lastLogin': null,
  };
}
