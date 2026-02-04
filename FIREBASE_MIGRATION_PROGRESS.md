# Firebase Migration Progress

## Status: Phase 1 Complete ✅

---

## Completed Tasks

### ✅ Task 1: Android Package Name Fixed

**What was done:**
- Updated `android/app/build.gradle.kts`:
  - Changed `namespace` from `com.amazingelearning.chikung` to `com.amazingelearning.chikung`
  - Changed `applicationId` from `com.amazingelearning.chikung` to `com.amazingelearning.chikung`
- Updated `MainActivity.kt` package declaration to `com.amazingelearning.chikung`
- Renamed folder structure from `chikung` to `chikung`
- Updated `app_constants.dart` bundle ID to `com.amazingelearning.chikung`

**Result:** Android package name now matches iOS bundle ID (`com.amazingelearning.chikung`)

**Files Modified:**
- `android/app/build.gradle.kts`
- `android/app/src/main/kotlin/com/ChiKung/chikung/MainActivity.kt` (renamed from chikung)
- `lib/core/constants/app_constants.dart`

---

### ✅ Task 2: Migration Scripts Created

**What was done:**
Created migration scripts in `/scripts` directory:

#### 1. upload_course_data.dart
- Reads hardcoded course data from app_constants structure
- Formats all 22 videos across 6 sections into Firestore-compatible JSON
- Calculates metadata (total videos, sections, duration)
- Exports to `course_data_export.json` for manual Firestore import
- Sets course as active, default, and premium

#### 2. create_admin_user.dart
- Creates admin user with credentials:
  - Username: `admin`
  - Password: `workout2026`
- Hashes password (basic implementation - upgrade for production)
- Exports to `admin_user_data.json` for manual Firestore import
- Sets role as "admin"

#### 3. scripts/README.md
- Complete documentation for running and using the scripts
- Instructions for manual Firestore import
- Troubleshooting guide

**How to Run:**
```bash
# Generate course data
dart run scripts/upload_course_data.dart

# Generate admin user data
dart run scripts/create_admin_user.dart
```

**Output Files:**
- `course_data_export.json` - Ready to import to Firestore `courses` collection
- `admin_user_data.json` - Ready to import to Firestore `users` collection

---

### ✅ Task 3: Firebase Integration Started

**What was done:**

#### Dependencies Added (pubspec.yaml)
```yaml
firebase_core: ^2.24.2
cloud_firestore: ^4.14.0
firebase_auth: ^4.16.0
```

#### Domain Entities Created
1. **lib/domain/entities/course.dart**
   - `Course` entity with all required fields
   - `CourseMetadata` nested entity
   - Methods: `totalVideos`, `totalDuration`, `allVideos`, `freeVideos`, `premiumVideos`
   - Fields: `id`, `name`, `description`, `isActive`, `isDefault`, `isFree`, `order`, `sections`, `metadata`

2. **lib/domain/entities/section.dart**
   - `Section` entity representing course sections
   - Fields: `id`, `sectionNumber`, `title`, `description`, `order`, `videos`
   - Methods: `totalDuration`, `videoCount`, `premiumVideoCount`, `freeVideoCount`

#### Data Models Created
1. **lib/data/models/course_model.dart**
   - Firestore serialization for Course
   - Methods: `fromFirestore()`, `fromMap()`, `toMap()`, `toEntity()`, `fromEntity()`
   - Handles Timestamp conversion
   - Includes `CourseMetadataModel`

2. **lib/data/models/section_model.dart**
   - Firestore serialization for Section
   - Methods: `fromMap()`, `toMap()`, `toEntity()`, `fromEntity()`

3. **lib/data/models/video_model.dart** (updated)
   - Added Firestore compatibility to existing VideoModel
   - Added `fromMap()` and `toMap()` methods
   - Handles Timestamp and Duration conversion

---

## Remaining Tasks

### 🔄 Phase 2: Complete Mobile App Firebase Integration

#### 1. Create Firestore Datasources
**To Do:**
- Create `lib/data/datasources/course_remote_datasource.dart`
  - Fetch courses from Firestore
  - Stream courses (real-time updates)
  - Get course by ID
  - Get default course
  - Get active courses
- Create `lib/data/datasources/course_local_datasource.dart`
  - Cache courses in Hive
  - Get cached courses
  - Save selected course ID
  - Get selected course ID

#### 2. Create Repositories
**To Do:**
- Create `lib/domain/repositories/course_repository.dart` (interface)
- Create `lib/data/repositories/course_repository_impl.dart` (implementation)
  - Fetch courses (remote, fallback to local)
  - Get default course
  - Get selected course
  - Set selected course
  - Stream courses

#### 3. Create Use Cases
**To Do:**
- `lib/domain/usecases/get_active_courses.dart`
- `lib/domain/usecases/get_default_course.dart`
- `lib/domain/usecases/get_selected_course.dart`
- `lib/domain/usecases/select_course.dart`
- `lib/domain/usecases/get_course_by_id.dart`

#### 4. Create Courses BLoC
**To Do:**
- Create `lib/presentation/courses/bloc/courses_bloc.dart`
- Create `lib/presentation/courses/bloc/courses_event.dart`
  - LoadCourses
  - SelectCourse
  - RefreshCourses
- Create `lib/presentation/courses/bloc/courses_state.dart`
  - CoursesInitial
  - CoursesLoading
  - CoursesLoaded
  - CourseSelected
  - CoursesError

#### 5. Create Courses UI
**To Do:**
- Create `lib/presentation/courses/pages/courses_page.dart`
  - List all active courses
  - Show course metadata (name, videos count, free/premium, selected)
  - Handle course selection
  - Material 3 design matching app theme
- Create `lib/presentation/courses/widgets/course_card.dart`
  - Display individual course
  - Show selected state
  - Show free/premium badge
- Update `lib/presentation/settings/pages/settings_page.dart`
  - Add "Courses" navigation tile

#### 6. Update Home Page
**To Do:**
- Update `lib/presentation/home/pages/home_page.dart`
  - Load videos from selected course instead of static data
  - Update section chips based on selected course
  - Handle empty state when no course selected
- Update `lib/presentation/video/bloc/video_bloc.dart`
  - Modify to work with course-based video loading
  - Filter videos by selected courseId

#### 7. Update Dependency Injection
**To Do:**
- Update `lib/injection_container.dart`
  - Register Firebase instances
  - Register course datasources
  - Register course repository
  - Register course use cases
  - Register courses bloc

#### 8. Firebase Initialization
**To Do:**
- Update `lib/main.dart`
  - Initialize Firebase: `await Firebase.initializeApp()`
  - Add error handling

#### 9. Update Storage Keys
**To Do:**
- Update `lib/core/constants/app_constants.dart`
  - Add `hiveCoursesBox = 'courses_box'`
  - Add `selectedCourseKey = 'selected_course_id'`
  - Add Firebase collection names

---

### 🔄 Phase 3: Manual Work (Your Tasks)

Follow `manual-work.md` for detailed instructions:

#### Firebase Console Setup
1. ✅ Create Firebase project
2. ✅ Register iOS app (download GoogleService-Info.plist)
3. ✅ Register Android app (download google-services.json)
4. ✅ Register Web app (get Firebase config)
5. ✅ Enable Firestore Database
6. ✅ Enable Firebase Authentication
7. ✅ Setup Firestore Security Rules
8. ✅ Setup Firebase Hosting (for web panel)

#### Firebase Configuration Files
1. ⏳ Place `GoogleService-Info.plist` in `ios/Runner/`
2. ⏳ Place `google-services.json` in `android/app/`
3. ⏳ Get `firebase-admin-key.json` for migration scripts

#### Run Migration Scripts
1. ⏳ Download `firebase-admin-key.json` from Firebase Console
2. ⏳ Run `dart run scripts/upload_course_data.dart`
3. ⏳ Run `dart run scripts/create_admin_user.dart`
4. ⏳ Import generated JSON files to Firestore manually
5. ⏳ Verify data in Firebase Console

---

### 🔄 Phase 4: Web Admin Panel (Your Task)

**Location**: `new-project/` folder (separate from mobile app)

Follow `new-project/web-panel.md` for complete specifications.

**What to Build:**
- Flutter Web application (in new-project folder)
- Admin authentication (username: admin, password: workout2026)
- Course management (CRUD operations)
- Section management (add, edit, reorder, delete)
- Video management (add, edit, reorder, delete)
- Material 3 design matching mobile app theme
- Deploy to Firebase Hosting

**Important**: Migration scripts stay in main project `/scripts` folder and will be run from there.

---

## Testing Checklist

### Mobile App Tests
- [ ] Run `flutter pub get` to install new Firebase dependencies
- [ ] Place Firebase config files (GoogleService-Info.plist, google-services.json)
- [ ] Test Firebase initialization
- [ ] Test fetching courses from Firestore
- [ ] Test course selection and persistence
- [ ] Test offline mode with cached data
- [ ] Test video playback from selected course
- [ ] Test section filtering from selected course

### Migration Scripts Tests
- [ ] Verify course_data_export.json structure
- [ ] Verify admin_user_data.json structure
- [ ] Import data to Firestore successfully
- [ ] Verify 22 videos across 6 sections in Firestore
- [ ] Verify admin user in Firestore

### Web Admin Panel Tests
- [ ] Admin login works
- [ ] Can view all courses
- [ ] Can create/edit/delete courses
- [ ] Can manage sections
- [ ] Can manage videos
- [ ] Changes reflect in mobile app

---

## Next Steps

### Immediate (After completing Firebase Console setup):
1. Place Firebase configuration files:
   - `ios/Runner/GoogleService-Info.plist`
   - `android/app/google-services.json`
2. Get `firebase-admin-key.json` from Firebase Console
3. Run migration scripts to generate JSON exports
4. Import data to Firestore (follow scripts/README.md)

### Then (Mobile App):
1. Run `flutter pub get` to install Firebase dependencies
2. Complete remaining Firestore datasources (I can help with this)
3. Complete repositories and use cases (I can help with this)
4. Complete BLoC implementation (I can help with this)
5. Build Courses UI (I can help with this)
6. Update Home page (I can help with this)
7. Test end-to-end

### Finally (Web Admin Panel):
1. Create new Flutter Web project (in separate directory)
2. Follow web-panel.md specifications
3. Implement authentication
4. Implement course management
5. Deploy to Firebase Hosting

---

## Documentation Files

All documentation has been created:
- ✅ `migration.md` - Complete migration roadmap and technical plan
- ✅ `manual-work.md` - Step-by-step manual tasks for you
- ✅ `new-project/web-panel.md` - Complete web admin panel specification
- ✅ `new-project/README.md` - Web admin panel project guide
- ✅ `scripts/README.md` - Migration scripts documentation
- ✅ `FIREBASE_MIGRATION_PROGRESS.md` - This file (progress tracker)

---

## Questions or Issues?

If you encounter any issues:
1. Check the relevant documentation file (migration.md, manual-work.md, web-panel.md)
2. Check Firebase Console for errors
3. Check Firestore security rules
4. Verify configuration files are in correct locations
5. Review migration scripts output

---

**Last Updated:** 2026-02-04
**Current Phase:** Phase 1 Complete, Phase 2 In Progress
**Next Action:** Complete Firebase Console setup following manual-work.md

