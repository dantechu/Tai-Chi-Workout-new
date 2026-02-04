# Qigong Workout - Project Structure

Complete overview of the project organization after Firebase migration.

---

## 📁 Folder Structure

```
qigong_workout/                          # Main Flutter mobile app project
│
├── android/                             # Android native code
│   └── app/
│       ├── build.gradle.kts            # Package ID: com.amazingelearning.chikung
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/amazingelearning/chikung/
│               └── MainActivity.kt
│
├── ios/                                 # iOS native code
│   └── Runner/
│       ├── Info.plist
│       └── GoogleService-Info.plist    # ← You'll place this here
│
├── lib/                                 # Flutter Dart code
│   ├── main.dart                       # App entry point
│   ├── core/                           # Constants, theme, utilities
│   │   └── constants/
│   │       └── app_constants.dart      # Bundle ID: com.amazingelearning.chikung
│   ├── domain/                         # Business entities, repositories
│   │   ├── entities/
│   │   │   ├── course.dart            # NEW: Course entity
│   │   │   ├── section.dart           # NEW: Section entity
│   │   │   ├── video.dart             # Existing video entity
│   │   │   └── lesson.dart
│   │   └── repositories/
│   ├── data/                           # Data layer, models, datasources
│   │   ├── models/
│   │   │   ├── course_model.dart      # NEW: Firestore course model
│   │   │   ├── section_model.dart     # NEW: Firestore section model
│   │   │   └── video_model.dart       # Updated with Firestore support
│   │   └── repositories/
│   └── presentation/                   # UI layer, BLoC, pages, widgets
│       ├── home/
│       ├── video/
│       ├── settings/
│       └── courses/                    # NEW: Course selection UI (to be built)
│
├── scripts/                             # 🔥 Migration Scripts (RUN FROM HERE)
│   ├── README.md                       # Scripts usage guide
│   ├── upload_course_data.dart         # Exports course to JSON for Firestore
│   └── create_admin_user.dart          # Creates admin user JSON
│
├── new-project/                         # 🌐 Web Admin Panel (SEPARATE PROJECT)
│   ├── README.md                       # Web panel project guide
│   ├── web-panel.md                    # Complete technical specifications
│   └── (you'll create Flutter Web project here)
│
├── migration.md                         # Complete migration roadmap
├── manual-work.md                       # Manual Firebase setup tasks
├── FIREBASE_MIGRATION_PROGRESS.md      # Progress tracker
├── PROJECT_STRUCTURE.md                # This file
├── pubspec.yaml                         # Dependencies (includes Firebase)
├── firebase-admin-key.json             # ← You'll place this here (gitignored)
└── google-services.json                # ← Placed in android/app/ (gitignored)
```

---

## 🎯 Project Components

### 1. Main Mobile App (Root Folder)
**Purpose**: iOS and Android app for end users
**Technology**: Flutter
**Package ID**: `com.amazingelearning.chikung`
**Firebase**: Reads course data from Firestore

**Key Features**:
- Video lessons (22 videos across 6 sections)
- Music meditation player
- Breathing timer
- Multi-language support (7 languages)
- Premium features (in-app purchase)
- Google AdMob integration
- **NEW**: Course selection from Firestore

---

### 2. Migration Scripts (`/scripts`)
**Purpose**: One-time data migration to Firestore
**Technology**: Dart command-line scripts
**Location**: Main project root
**Run From**: Main project root (NOT from web panel)

**Scripts**:
1. **upload_course_data.dart**
   - Reads hardcoded course data from app
   - Exports to `course_data_export.json`
   - Ready for manual Firestore import
   - Includes all 22 videos, 6 sections, metadata

2. **create_admin_user.dart**
   - Creates admin user credentials
   - Exports to `admin_user_data.json`
   - Username: `admin`, Password: `workout2026`

**How to Run**:
```bash
# From project root
dart run scripts/upload_course_data.dart
dart run scripts/create_admin_user.dart
```

**Output**: JSON files you manually import to Firestore

---

### 3. Web Admin Panel (`/new-project`)
**Purpose**: Web interface for managing course content
**Technology**: Flutter Web (separate project)
**Location**: `new-project/` folder
**Firebase**: Reads AND writes to Firestore

**Features** (to be built):
- Admin authentication
- Course CRUD operations
- Section management
- Video management
- Material 3 design
- Deploy to Firebase Hosting

**Documentation**:
- `new-project/README.md` - Project guide
- `new-project/web-panel.md` - Complete specifications

---

## 🔥 Firebase Architecture

### Firebase Project (One for All)
```
Firebase Project: qigong-tai-chi-workout
│
├── Firestore Database
│   ├── courses/              # Course documents
│   │   └── [courseId]
│   │       ├── name
│   │       ├── isActive
│   │       ├── isDefault
│   │       ├── isFree
│   │       └── sections[]
│   │           └── videos[]
│   │
│   └── users/                # Admin users
│       └── [userId]
│           ├── username
│           ├── password (hashed)
│           └── role
│
├── Authentication            # For web admin panel
│
├── Hosting                   # For web admin panel deployment
│
└── Registered Apps
    ├── iOS: com.amazingelearning.chikung
    ├── Android: com.amazingelearning.chikung
    └── Web: qigong_admin_panel
```

---

## 📊 Data Flow

### Initial Setup (One Time)
```
1. Main Project Scripts
   ├── upload_course_data.dart → course_data_export.json
   └── create_admin_user.dart → admin_user_data.json

2. Manual Import
   └── You import JSON files to Firestore Console

3. Firestore
   ├── courses collection (22 videos, 6 sections)
   └── users collection (admin user)
```

### Ongoing Usage
```
Mobile App (iOS/Android)          Web Admin Panel
        ↓                                ↓
    READ courses              READ & WRITE courses
        ↓                                ↓
              Firebase Firestore
                 ↓
         courses collection
                 ↓
    Auto-sync to all apps
```

---

## 🚀 Development Workflow

### Phase 1: Mobile App Firebase Integration ⏳
**Location**: Main project root
**Tasks**:
1. ✅ Add Firebase dependencies
2. ✅ Create domain entities (Course, Section)
3. ✅ Create Firestore models
4. ⏳ Create datasources (remote + local cache)
5. ⏳ Create repositories and use cases
6. ⏳ Create CoursesBloc
7. ⏳ Build Courses UI in Settings
8. ⏳ Update HomePage to use selected course
9. ⏳ Initialize Firebase in main.dart

### Phase 2: Firebase Console Setup ⏳
**Location**: Firebase Console (web)
**Tasks** (follow `manual-work.md`):
1. ⏳ Create Firebase project
2. ⏳ Register iOS app
3. ⏳ Register Android app
4. ⏳ Register Web app
5. ⏳ Enable Firestore, Authentication, Hosting
6. ⏳ Setup security rules
7. ⏳ Download config files

### Phase 3: Data Migration ⏳
**Location**: Main project root
**Tasks**:
1. ⏳ Place `firebase-admin-key.json` in project root
2. ⏳ Run `dart run scripts/upload_course_data.dart`
3. ⏳ Run `dart run scripts/create_admin_user.dart`
4. ⏳ Import JSON files to Firestore manually
5. ⏳ Verify data in Firestore Console

### Phase 4: Web Admin Panel 🔮
**Location**: `new-project/` folder
**Tasks**:
1. 🔮 Create Flutter Web project
2. 🔮 Configure Firebase for web
3. 🔮 Build authentication
4. 🔮 Build course management UI
5. 🔮 Deploy to Firebase Hosting

---

## 📝 Configuration Files

### Firebase Configuration Files (You'll Download)

| File | Location | Purpose |
|------|----------|---------|
| `GoogleService-Info.plist` | `ios/Runner/` | iOS Firebase config |
| `google-services.json` | `android/app/` | Android Firebase config |
| `firebase-admin-key.json` | Project root | For migration scripts |

### Bundle IDs (Must Match)

| Platform | Bundle ID | Location |
|----------|-----------|----------|
| iOS | `com.amazingelearning.chikung` | `ios/Runner.xcodeproj/project.pbxproj` |
| Android | `com.amazingelearning.chikung` | `android/app/build.gradle.kts` |
| Flutter | `com.amazingelearning.chikung` | `lib/core/constants/app_constants.dart` |
| MainActivity | `com.amazingelearning.chikung` | `android/.../MainActivity.kt` |

---

## 🔐 Security & Credentials

### Admin Credentials
- **Username**: `admin`
- **Password**: `workout2026`
- **Location**: Firestore `users` collection
- **⚠️ Change after first login!**

### Firebase Admin Key
- **File**: `firebase-admin-key.json`
- **Location**: Project root
- **Purpose**: Migration scripts
- **⚠️ Never commit to git!** (Already in `.gitignore`)

### Google Services
- **iOS**: `GoogleService-Info.plist`
- **Android**: `google-services.json`
- **⚠️ Never commit to git!** (Should be in `.gitignore`)

---

## 📚 Documentation Index

| Document | Purpose | Location |
|----------|---------|----------|
| `migration.md` | Complete migration plan | Project root |
| `manual-work.md` | Firebase setup tasks | Project root |
| `FIREBASE_MIGRATION_PROGRESS.md` | Progress tracker | Project root |
| `PROJECT_STRUCTURE.md` | This file | Project root |
| `scripts/README.md` | Migration scripts guide | `/scripts` |
| `new-project/README.md` | Web panel project guide | `/new-project` |
| `new-project/web-panel.md` | Web panel specifications | `/new-project` |

---

## 🎯 Quick Start Guide

### For Mobile App Development
```bash
# 1. Get dependencies
flutter pub get

# 2. Complete Firebase setup (follow manual-work.md)
# 3. Place config files (GoogleService-Info.plist, google-services.json)
# 4. Run migration scripts
dart run scripts/upload_course_data.dart
dart run scripts/create_admin_user.dart

# 5. Import JSON to Firestore manually
# 6. Run app
flutter run
```

### For Web Admin Panel Development
```bash
# 1. Navigate to new-project folder
cd new-project

# 2. Read documentation
cat README.md
cat web-panel.md

# 3. Create Flutter Web project
flutter create qigong_admin_panel
cd qigong_admin_panel

# 4. Follow web-panel.md specifications
# 5. Build and deploy
```

---

## ⚠️ Important Notes

### Migration Scripts Location
**Scripts are in the main project, NOT the web panel!**

Why?
- Scripts need access to main app's data structure
- First course upload uses existing app data
- Future courses will be added via web panel

### Running Scripts
Always run from main project root:
```bash
# ✅ Correct
cd /path/to/qigong_workout
dart run scripts/upload_course_data.dart

# ❌ Wrong
cd /path/to/qigong_workout/new-project
dart run ../scripts/upload_course_data.dart
```

### Package ID Consistency
All platforms MUST use: `com.amazingelearning.chikung`
- iOS already published with this ID
- Android updated to match
- Firebase apps registered with this ID

---

## 🧪 Testing Checklist

### Mobile App
- [ ] Firebase initializes without errors
- [ ] Can fetch courses from Firestore
- [ ] Can select and persist course choice
- [ ] Videos load from selected course
- [ ] Offline mode works with cached data
- [ ] Premium features still work

### Web Admin Panel
- [ ] Admin can login
- [ ] Can view all courses
- [ ] Can create/edit/delete courses
- [ ] Can manage sections and videos
- [ ] Changes reflect in Firestore
- [ ] Mobile app sees changes immediately

### Migration Scripts
- [ ] Scripts run without errors
- [ ] JSON files generated correctly
- [ ] Data imports to Firestore successfully
- [ ] All 22 videos present in Firestore
- [ ] Admin user exists in Firestore

---

**Last Updated**: 2026-02-04
**Status**: Phase 1 in progress
**Next**: Complete Firebase Console setup

