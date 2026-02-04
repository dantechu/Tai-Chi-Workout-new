/// Script to create admin user in Firestore
///
/// Prerequisites:
/// 1. Firebase project created with Firestore enabled
/// 2. firebase-admin-key.json file in project root
///
/// Usage:
/// dart run scripts/create_admin_user.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔐 Creating admin user in Firestore...\n');

  try {
    // Load Firebase Admin credentials
    final adminKeyFile = File('firebase-admin-key.json');
    if (!adminKeyFile.existsSync()) {
      print('❌ Error: firebase-admin-key.json not found in project root');
      print('   Please follow manual-work.md to generate this file from Firebase Console');
      exit(1);
    }

    final adminKey = jsonDecode(await adminKeyFile.readAsString());
    final projectId = adminKey['project_id'];
    print('✓ Firebase project: $projectId');

    // Prepare admin user data
    final adminUser = prepareAdminUser();
    print('✓ Admin user prepared:');
    print('  - Username: ${adminUser['username']}');
    print('  - Role: ${adminUser['role']}\n');

    // Save to JSON for manual import
    await saveAdminUserToJson(adminUser);

    print('\n✅ SUCCESS! Admin user data prepared');
    print('   Data exported to: admin_user_data.json\n');
    print('   To create the admin user:');
    print('   1. Go to Firebase Console > Firestore Database');
    print('   2. Create a new collection called "users"');
    print('   3. Add a new document with the data from admin_user_data.json\n');
    print('   Admin Credentials:');
    print('   Username: admin');
    print('   Password: workout2026\n');
    print('   ⚠️  IMPORTANT: Change this password after first login!\n');
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Prepare admin user data with hashed password
Map<String, dynamic> prepareAdminUser() {
  // For production, use bcrypt or similar
  // This is a simple hash for demonstration
  final password = 'workout2026';
  final hashedPassword = _simpleHash(password);

  return {
    'username': 'admin',
    'password': hashedPassword,
    'role': 'admin',
    'email': 'admin@amazingelearning.com',
    'createdAt': DateTime.now().toIso8601String(),
    'lastLogin': null,
  };
}

/// Simple hash function (for demonstration only)
/// In production, use bcrypt or similar
String _simpleHash(String password) {
  // This is NOT secure for production
  // Use bcrypt, argon2, or Firebase Auth instead
  var bytes = utf8.encode(password);
  var hash = 0;
  for (var byte in bytes) {
    hash = ((hash << 5) - hash) + byte;
    hash = hash & hash; // Convert to 32-bit integer
  }
  return 'simple_hash_${hash.abs()}';
}

/// Save admin user data to JSON file
Future<void> saveAdminUserToJson(Map<String, dynamic> userData) async {
  final jsonFile = File('admin_user_data.json');
  await jsonFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(userData),
  );
  print('✓ Admin user data exported to: admin_user_data.json');
}
