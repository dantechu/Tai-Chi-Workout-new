# Firebase Migration Plan

## Overview
Migrating the Qigong/Tai Chi Workout app from hardcoded local course data to Firebase/Firestore backend with multi-course support and web admin panel.

---

## Current State Analysis

### Existing Data Structure
- **Course**: Single hardcoded Tai Chi course in `app_constants.dart`
- **Sections**: 6 categories (About Us, Intro, Structure, Flexibility, Fluidity, Power)
- **Videos**: 22 videos total with metadata (title, description, isPremium, section, row)
- **Bundle ID Issue**: Android uses `com.amazingelearning.chikung` but iOS (published) uses `com.amazingelearning.chikung`

### Current Architecture
```
Domain Layer
├── entities/
│   ├── video.dart (id, title, category, videoUrl, sectionNumber, rowNumber, isPremium, description)
│   └── lesson.dart (section grouping of videos)

Data Layer
├── models/
├── repositories/
└── datasources/

Presentation Layer
└── BLoC pattern for state management
```

---

## Migration Goals

### 1. Firebase Integration
- [x] Research Firebase setup requirements
- [ ] Initialize Firebase for iOS
- [ ] Initialize Firebase for Android
- [ ] Setup Firestore database
- [ ] Configure Firebase security rules
- [ ] Setup Firebase authentication (for admin panel)

### 2. Data Model Design

#### Firestore Collections Structure

**Collection: `courses`**
```json
{
  "courseId": "auto-generated-id",
  "name": "Tai Chi Fundamentals",
  "description": "Complete Tai Chi training course",
  "isActive": true,
  "isDefault": true,
  "isFree": false,
  "order": 1,
  "thumbnailUrl": "https://...",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "sections": [
    {
      "sectionNumber": 1,
      "title": "About Us",
      "description": "Introduction to the course",
      "order": 1,
      "videos": [
        {
          "row": 1,
          "title": "About us",
          "description": "Learn about our Tai Chi program...",
          "videoUrl": "https://www.amazingonlinecourse.com/mobile/taichi/taichi_1_1.mp4",
          "thumbnailUrl": "https://...",
          "isPremium": false,
          "duration": 300,
          "tags": []
        }
      ]
    }
  ],
  "metadata": {
    "totalVideos": 22,
    "totalSections": 6,
    "totalDuration": 7200,
    "premiumVideos": 0,
    "freeVideos": 22
  }
}
```

**Collection: `users`**
```json
{
  "userId": "auto-generated-id",
  "username": "admin",
  "password": "hashed-workout2026",
  "role": "admin",
  "email": "admin@amazingelearning.com",
  "createdAt": "timestamp",
  "lastLogin": "timestamp"
}
```

**Collection: `app_users`** (for mobile users - future)
```json
{
  "userId": "device-id or firebase-auth-id",
  "selectedCourseId": "course-id-reference",
  "isPremium": false,
  "downloadedVideos": [],
  "favorites": [],
  "watchHistory": [],
  "createdAt": "timestamp"
}
```

### 3. Package Name Alignment
- [ ] Change Android package name from `com.amazingelearning.chikung` to `com.amazingelearning.chikung`
- [ ] Update all Android package references
- [ ] Update AndroidManifest.xml
- [ ] Update MainActivity.kt package declaration
- [ ] Update build.gradle applicationId
- [ ] Refactor folder structure in android/app/src/main/kotlin/

### 4. Mobile App Changes

#### New Domain Entities
- [ ] Create `Course` entity
  - id, name, description, isActive, isDefault, isFree, sections, metadata
- [ ] Update `Video` entity (add courseId reference)
- [ ] Update `Lesson` entity (add courseId reference)
- [ ] Create `Section` entity (to represent sections within a course)

#### New Data Layer
- [ ] Create Firestore datasources
  - `CourseRemoteDataSource` - fetch courses from Firestore
  - `CourseLocalDataSource` - cache courses in Hive
  - `VideoRemoteDataSource` - update to fetch from Firestore
- [ ] Create Firestore models
  - `CourseModel` with fromJson/toJson
  - `SectionModel` with fromJson/toJson
  - Update `VideoModel` for Firestore format
- [ ] Create repositories
  - `CourseRepository` - manage course CRUD operations
  - Update `VideoRepository` - fetch videos by courseId
- [ ] Create use cases
  - `GetActiveCourses` - fetch all active courses
  - `GetDefaultCourse` - fetch the default course
  - `SelectCourse` - save user's course selection
  - `GetSelectedCourse` - retrieve user's selected course
  - `GetCourseById` - fetch specific course details

#### New Presentation Layer
- [ ] Create `CoursesBloc`
  - States: Loading, Loaded, Error
  - Events: LoadCourses, SelectCourse, RefreshCourses
- [ ] Create `CoursesPage` in settings
  - Display all active courses
  - Show course metadata (name, free/premium, selected status)
  - Handle course selection
  - Material 3 design following current theme
- [ ] Create course selection widgets
  - `CourseCard` - display individual course with selection state
  - `CourseListTile` - simple list view option
- [ ] Update `HomePage`
  - Load videos from selected course instead of static data
  - Update section chips to reflect selected course sections
  - Handle empty state when no course selected
- [ ] Update `VideoBloc`
  - Modify to work with course-based video loading
  - Filter videos by selected courseId
- [ ] Update `SettingsPage`
  - Add "Courses" navigation tile
  - Follow current Material 3 theme

#### Storage Updates
- [ ] Add Hive boxes
  - `courses_box` - cache courses locally
  - `selected_course_box` - store user's course selection
- [ ] Add SharedPreferences keys
  - `selectedCourseId` - persist selected course
- [ ] Add to app_constants.dart
  - Firebase collection names
  - Course-related constants

### 5. Migration Scripts

#### Script 1: Course Data Upload (`upload_course_data.dart`)
- [ ] Read current videoCategories from app_constants.dart
- [ ] Transform into Firestore course document structure
- [ ] Calculate metadata (total videos, duration, etc.)
- [ ] Upload to Firestore `courses` collection
- [ ] Set isDefault: true, isActive: true, isFree: false
- [ ] Generate video URLs following pattern: `taichi_{section}_{row}.mp4`
- [ ] Handle error cases and logging

#### Script 2: Admin User Creation (`create_admin_user.dart`)
- [ ] Hash password "workout2026" securely
- [ ] Create admin user document in `users` collection
- [ ] Username: "admin"
- [ ] Role: "admin"
- [ ] Set timestamps
- [ ] Handle duplicates gracefully

### 6. Web Admin Panel

#### Authentication
- [ ] Create login page (Material 3, matching app theme)
- [ ] Implement username/password validation against Firestore
- [ ] Use Firebase Authentication or custom auth logic
- [ ] Session management (remember login)
- [ ] Logout functionality

#### Dashboard
- [ ] Course listing view
  - Display all courses in cards/table
  - Show course stats (videos, sections, status)
  - Quick actions: Edit, Delete, Toggle Active/Default
- [ ] Course creation
  - Form to add new course
  - Fields: name, description, isActive, isDefault, isFree
  - Upload thumbnail
- [ ] Course editing
  - Update course metadata
  - Add/remove/reorder sections
  - Add/remove/edit videos within sections
  - Drag-and-drop reordering
- [ ] Section management
  - Add new section to course
  - Edit section title/description
  - Reorder sections
  - Delete section
- [ ] Video management
  - Add video to section
  - Edit video metadata (title, description, URL, isPremium)
  - Upload video files (optional - or just URLs)
  - Delete video
  - Reorder videos within section

#### UI/UX Requirements
- [ ] Material 3 Design System
- [ ] Match app color scheme:
  - Primary: Tai Chi Green (#2E7D32)
  - Secondary: Earthy Brown (#8D6E63)
  - Accent: Calm Blue (#1976D2)
- [ ] Responsive design (desktop/tablet)
- [ ] Data validation and error handling
- [ ] Confirmation dialogs for destructive actions
- [ ] Loading states and progress indicators
- [ ] Toast notifications for actions

#### Technical Implementation
- [ ] Flutter Web project setup
- [ ] Firebase/Firestore integration
- [ ] State management (BLoC or Riverpod)
- [ ] Routing (go_router or auto_route)
- [ ] Form validation
- [ ] Image upload handling
- [ ] Real-time updates from Firestore
- [ ] Export/Import course data (JSON)

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Fix Android package name alignment
- [ ] Setup Firebase project (iOS + Android + Web)
- [ ] Create Firestore database structure
- [ ] Implement security rules
- [ ] Create and run migration scripts
- [ ] Verify data in Firestore console

### Phase 2: Mobile App - Data Layer (Week 1-2)
- [ ] Add Firebase dependencies to pubspec.yaml
- [ ] Create new domain entities (Course, Section)
- [ ] Create Firestore models and datasources
- [ ] Implement repositories and use cases
- [ ] Update dependency injection
- [ ] Test data fetching from Firestore

### Phase 3: Mobile App - Presentation Layer (Week 2)
- [ ] Create CoursesBloc and states
- [ ] Build CoursesPage UI
- [ ] Update HomePage to use selected course
- [ ] Update SettingsPage with Courses navigation
- [ ] Handle edge cases (no courses, no selection, offline)
- [ ] Test end-to-end course selection flow

### Phase 4: Web Admin Panel - Authentication (Week 3)
- [ ] Setup Flutter Web project
- [ ] Configure Firebase
- [ ] Build login UI
- [ ] Implement authentication logic
- [ ] Session management
- [ ] Protected routes

### Phase 5: Web Admin Panel - Dashboard (Week 3-4)
- [ ] Course listing view
- [ ] Course CRUD operations
- [ ] Section management
- [ ] Video management
- [ ] UI polish and validation
- [ ] Testing and bug fixes

### Phase 6: Testing & Deployment (Week 4)
- [ ] Integration testing (mobile + web)
- [ ] User acceptance testing
- [ ] Performance optimization
- [ ] Deploy web panel to Firebase Hosting
- [ ] Prepare mobile app updates for stores
- [ ] Documentation and training

---

## Technical Dependencies

### New Flutter Packages (Mobile)
```yaml
dependencies:
  # Firebase Core
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0 # Optional for future user auth

  # Firebase Storage (for video uploads - optional)
  firebase_storage: ^11.5.0
```

### Web Admin Panel Stack
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  firebase_storage: ^11.5.0

  # State Management
  flutter_bloc: ^8.1.3

  # Routing
  go_router: ^13.0.0

  # UI
  flutter_form_builder: ^9.1.1
  file_picker: ^6.1.1

  # Utilities
  intl: ^0.20.2
  crypto: ^3.0.3 # For password hashing
```

---

## Testing Strategy

### Mobile App Tests
- [ ] Unit tests for new entities
- [ ] Repository tests with mock Firestore
- [ ] BLoC tests for CoursesBloc
- [ ] Widget tests for CoursesPage
- [ ] Integration tests for course selection flow

### Web Admin Panel Tests
- [ ] Authentication flow tests
- [ ] Course CRUD operation tests
- [ ] Form validation tests
- [ ] End-to-end admin workflow tests

### Migration Script Tests
- [ ] Verify course data structure
- [ ] Validate all 22 videos uploaded
- [ ] Check metadata calculations
- [ ] Confirm admin user creation

---

## Rollback Plan

### If Migration Fails
1. Keep hardcoded data in app_constants.dart as fallback
2. Feature flag to toggle between local/Firebase data
3. Gradual rollout to test users first
4. Monitor Firestore usage and costs

### Data Backup
- Export current videoCategories as JSON
- Regular Firestore backups
- Version control for database structure changes

---

## Security Considerations

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Courses: Read for all, Write for admin only
    match /courses/{courseId} {
      allow read: if true;
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users: Admin only
    match /users/{userId} {
      allow read, write: if request.auth != null &&
                            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // App Users: Own data only
    match /app_users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Admin Panel Security
- Password hashing with bcrypt or Firebase Auth
- HTTPS only
- CORS configuration
- Rate limiting on login attempts
- Session timeout
- Audit logs for admin actions

---

## Performance Optimization

### Mobile App
- Local caching with Hive
- Lazy loading of course videos
- Pagination for large course lists
- Offline support with cached data
- Image optimization and CDN

### Web Admin Panel
- Firestore query optimization
- Pagination for large datasets
- Image compression before upload
- Debounced search/filter
- Lazy loading of course details

---

## Monitoring & Analytics

### Track in Firebase Analytics
- Course selection events
- Video playback by course
- Course popularity metrics
- Admin panel usage
- Error rates and types

### Firestore Usage Monitoring
- Document reads/writes
- Storage size
- Bandwidth usage
- Cost tracking

---

## Documentation Requirements

- [ ] API documentation for Firestore structure
- [ ] Admin panel user guide
- [ ] Mobile app course selection guide
- [ ] Migration script README
- [ ] Security rules documentation
- [ ] Deployment guides (web panel + mobile)

---

## Success Criteria

- ✅ All 22 existing videos migrated to Firestore
- ✅ Admin user created and can login
- ✅ Mobile app can fetch and display courses from Firestore
- ✅ Course selection persists across app restarts
- ✅ Web admin panel can add/edit/delete courses
- ✅ Android package name matches iOS bundle ID
- ✅ No breaking changes to existing users
- ✅ Performance remains same or better
- ✅ All tests passing

---

## Current Progress Tracker

### Completed ✅
- [x] Project analysis and data structure review
- [x] Migration plan documentation created

### In Progress 🔄
- [ ] Firebase setup
- [ ] Migration scripts

### Not Started ⏳
- [ ] Mobile app changes
- [ ] Web admin panel
- [ ] Testing
- [ ] Deployment

---

## Notes & Considerations

1. **Backwards Compatibility**: Consider keeping local data as fallback for offline-first experience
2. **Video URLs**: Current pattern uses `taichi_{section}_{row}.mp4` - maintain this for existing course
3. **Premium Status**: All current videos are free (isPremium: false) - web panel should allow toggling this
4. **Multi-language**: Current app supports 7 languages - future: localize course content
5. **Cost**: Monitor Firestore usage to stay within free tier or budget
6. **Scalability**: Design for 100+ courses and 1000+ videos
7. **Admin Roles**: Currently single admin, but structure allows multiple admins or role hierarchy

---

**Last Updated**: 2026-02-04
**Status**: Planning Phase
**Next Steps**: Create manual-work.md and web-panel.md, then begin Firebase setup
