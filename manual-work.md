# Manual Work Required

This document outlines all manual tasks that need to be performed on your side during the Firebase migration process.

---

## Phase 1: Firebase Project Setup

### Task 1.1: Create Firebase Project
**Estimated Time**: 10 minutes

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `qigong-tai-chi-workout` (or your preferred name)
4. Enable/Disable Google Analytics (recommended: enable)
5. If Analytics enabled, select or create Analytics account
6. Click "Create project" and wait for completion

**Deliverables**: Firebase project URL

---

### Task 1.2: Register iOS App in Firebase
**Estimated Time**: 5 minutes

1. In Firebase Console, click the iOS icon to add iOS app
2. Enter iOS bundle ID: `com.amazingelearning.chikung`
3. App nickname (optional): `Qigong Workout iOS`
4. App Store ID (optional): Your App Store ID
5. Click "Register app"
6. **Download `GoogleService-Info.plist`**
7. Save this file - you'll need to place it in the iOS project

**Deliverables**: `GoogleService-Info.plist` file

**File Placement** (I'll handle this in code):
```
ios/Runner/GoogleService-Info.plist
```

---

### Task 1.3: Register Android App in Firebase
**Estimated Time**: 5 minutes

1. In Firebase Console, click the Android icon to add Android app
2. Enter Android package name: `com.amazingelearning.chikung`
   - ⚠️ **Important**: Use `com.amazingelearning.chikung` (matching iOS), NOT the current `com.amazingelearning.chikung`
3. App nickname (optional): `Qigong Workout Android`
4. Debug signing certificate SHA-1 (optional for now, needed for Google Sign-In later)
   - To get SHA-1 on Mac: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
5. Click "Register app"
6. **Download `google-services.json`**
7. Save this file - you'll need to place it in the Android project

**Deliverables**: `google-services.json` file

**File Placement** (I'll handle this in code):
```
android/app/google-services.json
```

---

### Task 1.4: Register Web App in Firebase (for Admin Panel)
**Estimated Time**: 5 minutes

1. In Firebase Console, click the Web icon (</>)  to add Web app
2. Enter app nickname: `Qigong Admin Panel`
3. **Check** "Also set up Firebase Hosting"
4. Click "Register app"
5. **Copy the Firebase configuration object**:
```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
  measurementId: "..."
};
```
6. Save this configuration - I'll need it for the web panel

**Deliverables**: Firebase web config object (paste in a text file or keep the console open)

---

## Phase 2: Firebase Services Setup

### Task 2.1: Enable Firestore Database
**Estimated Time**: 3 minutes

1. In Firebase Console, go to "Build" > "Firestore Database"
2. Click "Create database"
3. Select **Production mode** (we'll add custom rules later)
4. Choose Firestore location:
   - Recommended: `us-central` (for US users)
   - Or choose closest to your target audience
5. Click "Enable"
6. Wait for database to be created

**Deliverables**: Firestore database URL (auto-generated)

---

### Task 2.2: Enable Firebase Authentication (for Admin Panel)
**Estimated Time**: 2 minutes

1. In Firebase Console, go to "Build" > "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable **Email/Password** provider:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Save
5. (Optional) Enable **Email link (passwordless sign-in)** if you want passwordless admin login

**Deliverables**: Screenshot of enabled auth providers

---

### Task 2.3: Enable Firebase Storage (Optional - for video/image uploads)
**Estimated Time**: 2 minutes

1. In Firebase Console, go to "Build" > "Storage"
2. Click "Get started"
3. Select **Production mode**
4. Choose storage location (same as Firestore recommended)
5. Click "Done"

**Deliverables**: Storage bucket URL

---

### Task 2.4: Setup Firebase Hosting (for Web Admin Panel)
**Estimated Time**: 3 minutes

1. In Firebase Console, go to "Build" > "Hosting"
2. Click "Get started"
3. You'll use Firebase CLI later (I'll provide commands)
4. Your hosting URL will be: `https://[your-project-id].web.app`

**Note**: Actual deployment will be done via CLI after web panel is built.

---

## Phase 3: Firestore Security Rules

### Task 3.1: Update Firestore Security Rules
**Estimated Time**: 5 minutes

1. In Firebase Console, go to "Firestore Database"
2. Click on "Rules" tab
3. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null &&
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Courses Collection
    // - Public read access (mobile apps need to fetch courses)
    // - Admin write access only
    match /courses/{courseId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    // Users Collection (Admin users)
    // - Admin read/write access only
    match /users/{userId} {
      allow read, write: if isAdmin();
      // Allow reading own user document for auth check
      allow get: if request.auth != null && request.auth.uid == userId;
    }

    // App Users Collection (Mobile app users - future use)
    match /app_users/{userId} {
      // Users can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Admin can read all
      allow read: if isAdmin();
    }

    // Settings Collection (App-wide settings - future use)
    match /settings/{settingId} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```

4. Click "Publish"
5. Confirm the rules are published

**Deliverables**: Screenshot of published rules

---

### Task 3.2: Setup Firestore Indexes (if needed)
**Estimated Time**: 2 minutes

Initially not required, but if you get index errors later:

1. Click on "Indexes" tab in Firestore
2. Firebase will suggest indexes if needed
3. Click "Create index" when prompted
4. Wait for index to build

**Note**: I'll let you know if specific indexes are needed during testing.

---

## Phase 4: Firebase Configuration Files Placement

### Task 4.1: Add GoogleService-Info.plist to iOS
**When**: After I modify the iOS project structure

You'll need to:
1. Open Xcode
2. Right-click on `Runner` folder
3. Select "Add Files to Runner..."
4. Select the `GoogleService-Info.plist` file you downloaded
5. **Important**: Check "Copy items if needed"
6. **Important**: Ensure "Runner" target is selected
7. Click "Add"

**Verification**: The file should appear in the `ios/Runner/` folder

---

### Task 4.2: Add google-services.json to Android
**When**: After I modify the Android project structure

You'll need to:
1. Copy the `google-services.json` file you downloaded
2. Paste it into: `android/app/` directory
3. Verify the file path is: `android/app/google-services.json`

**Verification**: File should be at the same level as `build.gradle`

---

## Phase 5: Running Migration Scripts

### Task 5.1: Provide Firebase Credentials for Scripts
**Estimated Time**: 10 minutes

Before running migration scripts, you'll need to:

1. Go to Firebase Console > Project Settings
2. Click on "Service accounts" tab
3. Click "Generate new private key"
4. Save the JSON file as: `firebase-admin-key.json`
5. **Keep this file secure** - it has admin access to your Firebase project
6. Place it in project root (it's already in .gitignore)

**Deliverables**: `firebase-admin-key.json` file in project root

⚠️ **Security Warning**: Never commit this file to git or share publicly!

---

### Task 5.2: Run Migration Scripts
**When**: After I create the scripts

I'll provide you with commands to run:
```bash
# Upload course data to Firestore
dart run scripts/upload_course_data.dart

# Create admin user
dart run scripts/create_admin_user.dart
```

**Expected Output**:
- Course successfully uploaded to Firestore
- Admin user created with credentials:
  - Username: admin
  - Password: workout2026

---

## Phase 6: Firestore Data Verification

### Task 6.1: Verify Course Data in Firestore
**Estimated Time**: 5 minutes

1. Go to Firebase Console > Firestore Database
2. Click on "Data" tab
3. Verify `courses` collection exists
4. Click on the first course document
5. Check:
   - `name` field exists
   - `isActive` is `true`
   - `isDefault` is `true`
   - `isFree` is `false`
   - `sections` array has 6 items
   - Each section has videos array
   - Total of 22 videos across all sections

**Deliverables**: Screenshot of Firestore console showing course data

---

### Task 6.2: Verify Admin User in Firestore
**Estimated Time**: 2 minutes

1. In Firestore console, check `users` collection
2. Verify admin user document exists
3. Check fields:
   - `username`: "admin"
   - `password`: (hashed value)
   - `role`: "admin"
   - `createdAt`: timestamp

**Deliverables**: Screenshot of users collection (blur password hash)

---

## Phase 7: Testing & Credentials

### Task 7.1: Admin Panel Login Test
**When**: After web panel is deployed

1. Navigate to admin panel URL (will be provided)
2. Enter credentials:
   - Username: `admin`
   - Password: `workout2026`
3. Verify you can login successfully
4. Test logout

**Deliverables**: Confirmation that login works

---

### Task 7.2: Mobile App Testing
**When**: After mobile app changes are complete

1. Install updated app on test device
2. Navigate to Settings > Courses
3. Verify course list loads from Firebase
4. Select the default course
5. Go to Home and verify videos load
6. Test offline mode (airplane mode)
7. Test course switching

**Deliverables**: Confirmation of successful mobile app testing

---

## Phase 8: Production Deployment

### Task 8.1: Update AdMob ID in AndroidManifest
**Before**: Publishing Android app

Current AndroidManifest has test AdMob ID:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

Replace with your production AdMob ID:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-9740790965972178~4504042514"/>
```

---

### Task 8.2: Update Firebase to Production Firestore Rules
**Before**: Public launch

Review and ensure security rules are production-ready (already done in Task 3.1)

---

### Task 8.3: Deploy Web Admin Panel
**When**: Web panel is ready

I'll provide Firebase CLI commands:
```bash
# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

**Deliverables**: Live admin panel URL

---

### Task 8.4: Enable Billing (if needed)
**When**: App gains traction

Firebase free tier limits:
- Firestore: 50K reads, 20K writes, 20K deletes per day
- Storage: 1GB stored, 10GB downloaded per month
- Hosting: 10GB storage, 360MB/day bandwidth

If you exceed these, you'll need to enable billing.

---

## Phase 9: Monitoring & Maintenance

### Task 9.1: Setup Firebase Alerts
**Estimated Time**: 5 minutes

1. Go to Firebase Console > Project Settings
2. Click "Integrations" tab
3. Setup email notifications for:
   - Budget alerts (if billing enabled)
   - Security rule violations
   - Unusual traffic

---

### Task 9.2: Regular Backups
**Recommendation**: Weekly

1. Use Firebase CLI to export Firestore data:
```bash
firebase firestore:export gs://[your-bucket]/backups/$(date +%Y%m%d)
```

2. Or use Firebase Console:
   - Firestore > Import/Export
   - Export data to Cloud Storage bucket

---

## Quick Reference Checklist

Use this checklist to track your progress:

- [ ] Create Firebase project
- [ ] Register iOS app, download GoogleService-Info.plist
- [ ] Register Android app, download google-services.json
- [ ] Register Web app, copy Firebase config
- [ ] Enable Firestore Database
- [ ] Enable Firebase Authentication
- [ ] Enable Firebase Storage (optional)
- [ ] Setup Firebase Hosting
- [ ] Update Firestore Security Rules
- [ ] Generate Firebase Admin SDK key (firebase-admin-key.json)
- [ ] Place GoogleService-Info.plist in iOS project
- [ ] Place google-services.json in Android project
- [ ] Run migration scripts
- [ ] Verify course data in Firestore console
- [ ] Verify admin user in Firestore console
- [ ] Test admin panel login
- [ ] Test mobile app with Firebase
- [ ] Update production AdMob ID
- [ ] Deploy web admin panel
- [ ] Setup monitoring and alerts

---

## Support & Troubleshooting

### Common Issues

**Issue**: "Default FirebaseApp is not initialized"
**Solution**: Ensure config files are in correct locations and Firebase.initializeApp() is called in main.dart

**Issue**: "Permission denied" in Firestore
**Solution**: Check security rules are published correctly

**Issue**: "Package name mismatch" on Android
**Solution**: Ensure all references to old package name are updated

**Issue**: Migration script fails
**Solution**: Verify firebase-admin-key.json is in project root and has correct permissions

---

## Contact Points

If you encounter issues during manual setup:

1. **Firebase Console Issues**: [Firebase Support](https://firebase.google.com/support)
2. **Configuration Questions**: Review [Firebase Setup Docs](https://firebase.google.com/docs/flutter/setup)
3. **Migration Script Issues**: Share error logs for debugging

---

**Last Updated**: 2026-02-04
**Status**: Ready for execution
**Estimated Total Time**: ~1-2 hours for complete manual setup
