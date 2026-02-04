import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Uploading data to Firestore...\n');

  final projectId = 'qigong-workout';

  try {
    // Upload course data
    print('📤 Uploading course...');
    await uploadCourse(projectId);

    // Upload admin user
    print('📤 Uploading admin user...');
    await uploadAdminUser(projectId);

    print('\n✅ SUCCESS! All data uploaded to Firestore');
    print('   Check: https://console.firebase.google.com/project/$projectId/firestore\n');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<void> uploadCourse(String projectId) async {
  final file = File('course_data_export.json');
  final courseData = jsonDecode(await file.readAsString());

  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/courses/tai_chi_fundamentals';

  final response = await http.patch(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fields': _convertToFirestoreFormat(courseData),
    }),
  );

  if (response.statusCode == 200) {
    print('   ✓ Course uploaded');
  } else {
    throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
  }
}

Future<void> uploadAdminUser(String projectId) async {
  final file = File('admin_user_data.json');
  final userData = jsonDecode(await file.readAsString());

  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/admin_user';

  final response = await http.patch(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fields': _convertToFirestoreFormat(userData),
    }),
  );

  if (response.statusCode == 200) {
    print('   ✓ Admin user uploaded');
  } else {
    throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
  }
}

Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
  final result = <String, dynamic>{};

  data.forEach((key, value) {
    result[key] = _convertValue(value);
  });

  return result;
}

dynamic _convertValue(dynamic value) {
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
        'values': value.map((item) => _convertValue(item)).toList(),
      }
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': _convertToFirestoreFormat(Map<String, dynamic>.from(value)),
      }
    };
  }
  return {'stringValue': value.toString()};
}
