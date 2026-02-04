# Migration Scripts

This directory contains scripts to migrate the Qigong Workout app data to Firebase Firestore.

## Scripts

### 1. upload_course_data.dart
Uploads the existing Tai Chi course data (22 videos, 6 sections) to Firestore.

**What it does:**
- Reads the hardcoded course data from app_constants.dart structure
- Formats it into Firestore-compatible JSON
- Exports to `course_data_export.json` for manual import
- Calculates metadata (total videos, sections, duration)

**Usage:**
```bash
dart run scripts/upload_course_data.dart
```

**Output:**
- `course_data_export.json` - Course data ready for Firestore import

### 2. create_admin_user.dart
Creates the admin user for the web admin panel.

**What it does:**
- Creates admin user with username "admin" and password "workout2026"
- Hashes the password (basic implementation - upgrade for production)
- Exports to `admin_user_data.json` for manual import

**Usage:**
```bash
dart run scripts/create_admin_user.dart
```

**Output:**
- `admin_user_data.json` - Admin user data ready for Firestore import

**Default Credentials:**
- Username: `admin`
- Password: `workout2026`
- ⚠️ Change password after first login!

## Prerequisites

1. Firebase project created
2. Firestore Database enabled
3. `firebase-admin-key.json` in project root (get from Firebase Console > Project Settings > Service Accounts)

## Manual Import to Firestore

After running the scripts:

### Import Course Data

1. Go to Firebase Console > Firestore Database
2. Click "Start collection"
3. Collection ID: `courses`
4. Click "Add document"
5. Copy the content from `course_data_export.json`
6. Paste into the document fields
7. Save

### Import Admin User

1. In Firestore Database, click "Start collection" (if not exists)
2. Collection ID: `users`
3. Click "Add document"
4. Copy the content from `admin_user_data.json`
5. Paste into the document fields
6. Save

## Automated Import (Advanced)

For automated import, install Firebase Admin SDK:

```bash
dart pub add firebase_admin
```

Then modify the scripts to use the Firebase Admin SDK for direct Firestore writes.

## Security Note

- Never commit `firebase-admin-key.json` to version control
- It's already in `.gitignore`
- Keep this file secure - it has full admin access to your Firebase project

## Troubleshooting

**Error: firebase-admin-key.json not found**
- Download from Firebase Console > Project Settings > Service Accounts
- Click "Generate new private key"
- Save as `firebase-admin-key.json` in project root

**Error: Permission denied**
- Ensure Firestore security rules allow write access
- Verify the service account has the correct permissions

## Next Steps

After importing data:

1. Verify data in Firebase Console
2. Test fetching data from mobile app
3. Deploy web admin panel
4. Test admin login with credentials above
