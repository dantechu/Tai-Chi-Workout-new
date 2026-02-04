# Web Admin Panel Documentation

Complete technical specification for the Qigong/Tai Chi Workout Web Admin Panel.

---

## Overview

A Flutter Web application for managing courses, sections, and videos in the Qigong Workout mobile app. Built with Material 3 design matching the mobile app's theme and connected to Firebase Firestore.

---

## Architecture

### Technology Stack

```yaml
Platform: Flutter Web
State Management: flutter_bloc
Backend: Firebase (Firestore + Authentication)
Routing: go_router
UI Framework: Material 3
Deployment: Firebase Hosting
```

### Project Structure

```
qigong_admin_panel/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── firebase_constants.dart
│   │   │   └── theme_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── dialogs.dart
│   │   └── errors/
│   │       └── failures.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── course.dart
│   │   │   ├── section.dart
│   │   │   ├── video.dart
│   │   │   └── admin_user.dart
│   │   └── repositories/
│   │       ├── course_repository.dart
│   │       ├── auth_repository.dart
│   │       └── storage_repository.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── course_model.dart
│   │   │   ├── section_model.dart
│   │   │   ├── video_model.dart
│   │   │   └── admin_user_model.dart
│   │   ├── datasources/
│   │   │   ├── firestore_datasource.dart
│   │   │   └── auth_datasource.dart
│   │   └── repositories/
│   │       ├── course_repository_impl.dart
│   │       ├── auth_repository_impl.dart
│   │       └── storage_repository_impl.dart
│   ├── presentation/
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── pages/
│   │   │       └── login_page.dart
│   │   ├── dashboard/
│   │   │   ├── bloc/
│   │   │   │   ├── dashboard_bloc.dart
│   │   │   │   ├── dashboard_event.dart
│   │   │   │   └── dashboard_state.dart
│   │   │   ├── pages/
│   │   │   │   └── dashboard_page.dart
│   │   │   └── widgets/
│   │   │       ├── course_list.dart
│   │   │       ├── course_card.dart
│   │   │       ├── stats_card.dart
│   │   │       └── sidebar.dart
│   │   ├── courses/
│   │   │   ├── bloc/
│   │   │   │   ├── courses_bloc.dart
│   │   │   │   ├── courses_event.dart
│   │   │   │   └── courses_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── course_list_page.dart
│   │   │   │   ├── course_create_page.dart
│   │   │   │   └── course_edit_page.dart
│   │   │   └── widgets/
│   │   │       ├── course_form.dart
│   │   │       ├── section_list.dart
│   │   │       └── video_list.dart
│   │   ├── sections/
│   │   │   ├── bloc/
│   │   │   │   ├── section_bloc.dart
│   │   │   │   ├── section_event.dart
│   │   │   │   └── section_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── section_create_page.dart
│   │   │   │   └── section_edit_page.dart
│   │   │   └── widgets/
│   │   │       ├── section_form.dart
│   │   │       └── reorder_sections.dart
│   │   ├── videos/
│   │   │   ├── bloc/
│   │   │   │   ├── video_bloc.dart
│   │   │   │   ├── video_event.dart
│   │   │   │   └── video_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── video_create_page.dart
│   │   │   │   └── video_edit_page.dart
│   │   │   └── widgets/
│   │   │       ├── video_form.dart
│   │   │       ├── video_preview.dart
│   │   │       └── reorder_videos.dart
│   │   └── common/
│   │       └── widgets/
│   │           ├── app_bar.dart
│   │           ├── loading_overlay.dart
│   │           ├── error_widget.dart
│   │           └── confirm_dialog.dart
│   └── injection_container.dart
├── web/
│   ├── index.html
│   └── manifest.json
├── firebase.json
├── .firebaserc
└── pubspec.yaml
```

---

## Design System

### Color Palette (Material 3)

Matching the mobile app theme:

```dart
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2E7D32);        // Tai Chi Green
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFA5D6A7);
  static const onPrimaryContainer = Color(0xFF1B5E20);

  // Secondary Colors
  static const secondary = Color(0xFF8D6E63);      // Earthy Brown
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD7CCC8);
  static const onSecondaryContainer = Color(0xFF5D4037);

  // Accent Colors
  static const accent = Color(0xFF1976D2);         // Calm Blue
  static const onAccent = Color(0xFFFFFFFF);

  // Background
  static const background = Color(0xFFFAFAFA);
  static const onBackground = Color(0xFF1A1A1A);

  // Surface
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFFF5F5F5);

  // Error
  static const error = Color(0xFFD32F2F);
  static const onError = Color(0xFFFFFFFF);

  // Status Colors
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
  static const info = Color(0xFF0288D1);
}
```

### Typography

```dart
TextTheme textTheme = TextTheme(
  displayLarge: GoogleFonts.roboto(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  ),
  displayMedium: GoogleFonts.roboto(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  ),
  displaySmall: GoogleFonts.roboto(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  ),
  headlineLarge: GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  ),
  headlineMedium: GoogleFonts.roboto(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  ),
  headlineSmall: GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  ),
  titleLarge: GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  ),
  titleMedium: GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyLarge: GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyMedium: GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  bodySmall: GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  labelLarge: GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelMedium: GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
);
```

---

## Features Specification

### 1. Authentication

#### 1.1 Login Page

**URL**: `/login`

**UI Components**:
- App logo (centered)
- App title "Qigong Workout Admin Panel"
- Username text field
- Password text field (obscured)
- "Remember me" checkbox
- Login button
- Loading indicator during authentication
- Error message display

**Validation**:
- Username: Required, min 3 characters
- Password: Required, min 6 characters

**Authentication Flow**:
```dart
1. User enters credentials
2. Validate input locally
3. Hash password (if not using Firebase Auth)
4. Query Firestore users collection
5. Compare credentials
6. If match:
   - Create session
   - Store auth token in local storage
   - Navigate to dashboard
7. If no match:
   - Show error message
   - Clear password field
```

**Security**:
- Passwords stored as bcrypt hash in Firestore
- Session timeout: 24 hours
- Auto-logout on browser close (unless "Remember me")
- HTTPS only

#### 1.2 Session Management

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Events
  - LoginRequested(username, password)
  - LogoutRequested()
  - SessionCheckRequested()
  - SessionExpired()

  // States
  - AuthInitial()
  - AuthLoading()
  - Authenticated(adminUser)
  - Unauthenticated()
  - AuthError(message)
}
```

---

### 2. Dashboard

#### 2.1 Dashboard Page

**URL**: `/dashboard`

**Layout**:
```
┌─────────────────────────────────────────────────┐
│  App Bar (Logout, Admin Name)                   │
├─────────┬───────────────────────────────────────┤
│         │                                        │
│ Sidebar │  Main Content Area                    │
│         │                                        │
│ - Dash  │  [Stats Cards]                        │
│ - Cours │  [Recent Activity]                    │
│ - Settin│  [Quick Actions]                      │
│         │                                        │
└─────────┴───────────────────────────────────────┘
```

**Stats Cards**:
1. **Total Courses**
   - Number of all courses
   - Active vs Inactive count
   - Icon: SchoolIcon

2. **Total Videos**
   - Total video count across all courses
   - Premium vs Free count
   - Icon: VideoCameraBackIcon

3. **Total Sections**
   - Sum of all sections
   - Average videos per section
   - Icon: ViewModuleIcon

4. **Storage Used**
   - Total storage (if using Firebase Storage)
   - Remaining quota
   - Icon: CloudIcon

**Recent Activity Feed**:
- Last 10 admin actions
- Timestamps
- Action type (Created, Updated, Deleted)
- Resource (Course, Section, Video)

**Quick Actions**:
- Create New Course (Primary Button)
- View All Courses (Outlined Button)
- Backup Data (Text Button)

---

### 3. Course Management

#### 3.1 Course List Page

**URL**: `/courses`

**UI Components**:

**Header**:
- Page title: "Courses"
- Search bar (search by name, description)
- Filter dropdown (All, Active, Inactive, Free, Premium)
- Sort dropdown (Name, Date Created, Date Updated)
- "Create Course" button (FAB or Header Button)

**Course List** (Data Table or Card Grid):

**Table Columns**:
| Thumbnail | Name | Sections | Videos | Status | Default | Free | Actions |
|-----------|------|----------|--------|--------|---------|------|---------|
| [img]     | Tai Chi... | 6 | 22 | Active | Yes | No | Edit/Delete |

**Card View** (Alternative):
```
┌────────────────────────────────────┐
│  [Thumbnail]                       │
│  Course Name                       │
│  6 Sections • 22 Videos            │
│  ● Active  ⭐ Default  💰 Premium  │
│  [Edit] [Delete] [Toggle Status]  │
└────────────────────────────────────┘
```

**Actions**:
- Edit (pencil icon) - Navigate to edit page
- Delete (trash icon) - Show confirmation dialog
- Toggle Active (switch) - Update isActive in Firestore
- Set as Default (star icon) - Set isDefault, unset others
- Clone (copy icon) - Duplicate course

#### 3.2 Course Create/Edit Page

**URL**: `/courses/create` or `/courses/:id/edit`

**Form Fields**:

1. **Course Name*** (Required)
   - Text input
   - Max 100 characters
   - Validation: Required, no special chars

2. **Description**
   - Multiline text input
   - Max 500 characters
   - Rich text editor (optional)

3. **Thumbnail Image**
   - File picker (image upload)
   - Accepted: jpg, png, webp
   - Max size: 2MB
   - Preview thumbnail

4. **Is Active*** (Required)
   - Switch toggle
   - Default: true
   - Label: "Active (visible to mobile users)"

5. **Is Default*** (Required)
   - Switch toggle
   - Default: false
   - Label: "Default (auto-selected for new users)"
   - Warning: "Only one course can be default"

6. **Is Free*** (Required)
   - Switch toggle
   - Default: false
   - Label: "Free (available without premium)"

7. **Display Order**
   - Number input
   - Min: 1
   - Used for sorting courses

**Sections** (Nested Form):
- List of existing sections (if editing)
- "Add Section" button
- Each section can be expanded to show videos
- Drag-to-reorder sections
- Delete section button (with confirmation)

**Form Actions**:
- Save & Close (Primary)
- Save & Add Section (Secondary)
- Cancel (Text Button)
- Delete Course (if editing, Destructive)

**Validation**:
```dart
- Name: Required, 3-100 chars
- Description: Max 500 chars
- Thumbnail: Valid image URL or file
- At least one section (warning, not blocking)
- If isDefault = true, check no other course is default
```

#### 3.3 Course Actions & Dialogs

**Delete Course Dialog**:
```
┌─────────────────────────────────────┐
│  ⚠️  Delete Course?                 │
│                                     │
│  Are you sure you want to delete   │
│  "[Course Name]"?                  │
│                                     │
│  This will delete:                 │
│  • 6 sections                      │
│  • 22 videos                       │
│  • All associated data             │
│                                     │
│  This action cannot be undone.     │
│                                     │
│  [Cancel]  [Delete Course]         │
└─────────────────────────────────────┘
```

**Clone Course Dialog**:
```
┌─────────────────────────────────────┐
│  📋  Clone Course?                  │
│                                     │
│  New Course Name:                  │
│  [Tai Chi Fundamentals (Copy)   ] │
│                                     │
│  ☑ Copy all sections               │
│  ☑ Copy all videos                 │
│  ☐ Set as active                   │
│  ☐ Set as default                  │
│                                     │
│  [Cancel]  [Clone Course]          │
└─────────────────────────────────────┘
```

---

### 4. Section Management

#### 4.1 Section Form (Inline in Course Edit)

**Fields**:

1. **Section Title*** (Required)
   - Text input
   - Max 100 characters
   - Example: "Structure", "Flexibility"

2. **Section Number*** (Required)
   - Number input
   - Auto-incremented
   - Used for ordering

3. **Description**
   - Multiline text
   - Max 300 characters

4. **Order**
   - Number input
   - For custom sorting

**Actions**:
- Add Video to Section
- Reorder Videos (drag-drop)
- Delete Section
- Collapse/Expand Section

#### 4.2 Section Reordering

**UI**:
- Drag handle icon (☰) on each section card
- Drag-and-drop to reorder
- Auto-save order on drop
- Visual feedback during drag
- Toast notification on save

**Implementation**:
```dart
ReorderableListView.builder(
  onReorder: (oldIndex, newIndex) {
    // Update section order numbers
    // Save to Firestore
  },
  itemBuilder: (context, index) {
    return SectionCard(
      key: ValueKey(section.id),
      section: sections[index],
    );
  },
)
```

---

### 5. Video Management

#### 5.1 Video Create/Edit Form

**URL**: `/courses/:courseId/sections/:sectionId/videos/create`

**Form Fields**:

1. **Video Title*** (Required)
   - Text input
   - Max 150 characters
   - Example: "Structure Part 1"

2. **Description**
   - Rich text editor
   - Max 2000 characters
   - Supports formatting (bold, italic, lists)

3. **Video URL*** (Required)
   - Text input (URL)
   - Validation: Must be valid URL
   - Example: `https://www.amazingonlinecourse.com/mobile/taichi/taichi_3_1.mp4`
   - Video URL pattern helper (optional)

4. **Thumbnail URL**
   - Text input or file upload
   - Image URL or upload
   - Auto-generate from video (optional)

5. **Row Number*** (Required)
   - Number input
   - Determines order within section
   - Auto-incremented

6. **Duration**
   - Time picker (minutes:seconds)
   - Or auto-detect from video file

7. **Is Premium**
   - Switch toggle
   - Default: false
   - Label: "Premium only (requires in-app purchase)"

8. **Tags**
   - Chip input
   - Comma-separated
   - Example: "beginner", "meditation", "breathing"

**Form Actions**:
- Save & Close
- Save & Add Another
- Preview Video
- Cancel
- Delete Video (if editing)

**Video Preview**:
- Inline video player
- Shows video from URL
- Validates URL is accessible
- Display metadata (resolution, duration, size)

#### 5.2 Video List (Within Section)

**Display**:
```
Section: Structure
┌─────────────────────────────────────────────────┐
│ ☰ 1. Structure Part 1                     [●]  │
│    Duration: 5:23 • Premium: No                │
│    [Edit] [Delete] [Preview]                   │
├─────────────────────────────────────────────────┤
│ ☰ 2. Structure Part 2                     [●]  │
│    Duration: 6:15 • Premium: No                │
│    [Edit] [Delete] [Preview]                   │
├─────────────────────────────────────────────────┤
│ ☰ 3. Structure Part 3                     [●]  │
│    Duration: 4:58 • Premium: No                │
│    [Edit] [Delete] [Preview]                   │
└─────────────────────────────────────────────────┘
[+ Add Video]
```

**Features**:
- Drag-and-drop reordering
- Quick toggle premium status
- Inline edit (title, description)
- Bulk actions (delete, toggle premium)

---

### 6. Settings

#### 6.1 Settings Page

**URL**: `/settings`

**Sections**:

**Admin Profile**:
- Change username
- Change password
- Email (if added)

**App Configuration**:
- Default course selection
- Video URL base path
- Thumbnail placeholder URL

**Data Management**:
- Export all courses (JSON)
- Import courses (JSON upload)
- Backup database
- Clear cache

**Danger Zone**:
- Delete all courses (confirmation required)
- Reset to default data

---

## BLoC Architecture

### Courses BLoC

```dart
// Events
abstract class CoursesEvent {}
class LoadCourses extends CoursesEvent {}
class CreateCourse extends CoursesEvent {
  final Course course;
}
class UpdateCourse extends CoursesEvent {
  final Course course;
}
class DeleteCourse extends CoursesEvent {
  final String courseId;
}
class ToggleCourseActive extends CoursesEvent {
  final String courseId;
}
class SetDefaultCourse extends CoursesEvent {
  final String courseId;
}
class CloneCourse extends CoursesEvent {
  final String courseId;
  final String newName;
}

// States
abstract class CoursesState {}
class CoursesInitial extends CoursesState {}
class CoursesLoading extends CoursesState {}
class CoursesLoaded extends CoursesState {
  final List<Course> courses;
}
class CourseOperationSuccess extends CoursesState {
  final String message;
}
class CoursesError extends CoursesState {
  final String message;
}
```

### Section BLoC

```dart
// Events
abstract class SectionEvent {}
class LoadSections extends SectionEvent {
  final String courseId;
}
class CreateSection extends SectionEvent {
  final String courseId;
  final Section section;
}
class UpdateSection extends SectionEvent {
  final String courseId;
  final Section section;
}
class DeleteSection extends SectionEvent {
  final String courseId;
  final String sectionId;
}
class ReorderSections extends SectionEvent {
  final String courseId;
  final List<Section> sections;
}

// States
abstract class SectionState {}
class SectionInitial extends SectionState {}
class SectionLoading extends SectionState {}
class SectionsLoaded extends SectionState {
  final List<Section> sections;
}
class SectionOperationSuccess extends SectionState {
  final String message;
}
class SectionError extends SectionState {
  final String message;
}
```

### Video BLoC

```dart
// Events
abstract class VideoEvent {}
class LoadVideos extends VideoEvent {
  final String courseId;
  final String sectionId;
}
class CreateVideo extends VideoEvent {
  final String courseId;
  final String sectionId;
  final Video video;
}
class UpdateVideo extends VideoEvent {
  final String courseId;
  final String sectionId;
  final Video video;
}
class DeleteVideo extends VideoEvent {
  final String courseId;
  final String sectionId;
  final String videoId;
}
class ReorderVideos extends VideoEvent {
  final String courseId;
  final String sectionId;
  final List<Video> videos;
}

// States
abstract class VideoState {}
class VideoInitial extends VideoState {}
class VideoLoading extends VideoState {}
class VideosLoaded extends VideoState {
  final List<Video> videos;
}
class VideoOperationSuccess extends VideoState {
  final String message;
}
class VideoError extends VideoState {
  final String message;
}
```

---

## Routing

### Route Structure

```dart
final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Check auth status
    final isAuthenticated = context.read<AuthBloc>().state is Authenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoginRoute) {
      return '/login';
    }
    if (isAuthenticated && isLoginRoute) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardPage(),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => CourseListPage(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => CourseCreatePage(),
        ),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) {
            final courseId = state.pathParameters['id']!;
            return CourseEditPage(courseId: courseId);
          },
          routes: [
            GoRoute(
              path: 'sections/create',
              builder: (context, state) {
                final courseId = state.pathParameters['id']!;
                return SectionCreatePage(courseId: courseId);
              },
            ),
            GoRoute(
              path: 'sections/:sectionId/edit',
              builder: (context, state) {
                final courseId = state.pathParameters['id']!;
                final sectionId = state.pathParameters['sectionId']!;
                return SectionEditPage(
                  courseId: courseId,
                  sectionId: sectionId,
                );
              },
              routes: [
                GoRoute(
                  path: 'videos/create',
                  builder: (context, state) {
                    final courseId = state.pathParameters['id']!;
                    final sectionId = state.pathParameters['sectionId']!;
                    return VideoCreatePage(
                      courseId: courseId,
                      sectionId: sectionId,
                    );
                  },
                ),
                GoRoute(
                  path: 'videos/:videoId/edit',
                  builder: (context, state) {
                    final courseId = state.pathParameters['id']!;
                    final sectionId = state.pathParameters['sectionId']!;
                    final videoId = state.pathParameters['videoId']!;
                    return VideoEditPage(
                      courseId: courseId,
                      sectionId: sectionId,
                      videoId: videoId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
  ],
);
```

---

## Firebase Integration

### Firestore CRUD Operations

#### Create Course
```dart
Future<void> createCourse(Course course) async {
  final courseData = {
    'name': course.name,
    'description': course.description,
    'isActive': course.isActive,
    'isDefault': course.isDefault,
    'isFree': course.isFree,
    'order': course.order,
    'thumbnailUrl': course.thumbnailUrl,
    'sections': course.sections.map((s) => s.toMap()).toList(),
    'metadata': {
      'totalVideos': course.totalVideos,
      'totalSections': course.totalSections,
      'totalDuration': course.totalDuration,
    },
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  // If setting as default, unset others first
  if (course.isDefault) {
    await _unsetOtherDefaults();
  }

  await _firestore.collection('courses').add(courseData);
}
```

#### Update Course
```dart
Future<void> updateCourse(Course course) async {
  if (course.isDefault) {
    await _unsetOtherDefaults(exceptId: course.id);
  }

  await _firestore.collection('courses').doc(course.id).update({
    'name': course.name,
    'description': course.description,
    'isActive': course.isActive,
    'isDefault': course.isDefault,
    'isFree': course.isFree,
    'sections': course.sections.map((s) => s.toMap()).toList(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

#### Delete Course
```dart
Future<void> deleteCourse(String courseId) async {
  // Add to deleted_courses for audit
  final courseDoc = await _firestore.collection('courses').doc(courseId).get();
  await _firestore.collection('deleted_courses').add({
    ...courseDoc.data()!,
    'deletedAt': FieldValue.serverTimestamp(),
  });

  // Delete the course
  await _firestore.collection('courses').doc(courseId).delete();
}
```

#### Get All Courses
```dart
Stream<List<Course>> getCourses() {
  return _firestore
      .collection('courses')
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Course.fromFirestore(doc))
        .toList();
  });
}
```

---

## Deployment

### Build for Production

```bash
# Build web app
flutter build web --release --web-renderer html

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Firebase Hosting Configuration

`firebase.json`:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|js|css|woff|woff2)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

---

## Testing Strategy

### Unit Tests
- Entity validation
- Form validators
- Utility functions
- Date formatters

### BLoC Tests
- Auth flow
- CRUD operations
- State transitions
- Error handling

### Widget Tests
- Login form
- Course form
- Section list
- Video list

### Integration Tests
- End-to-end course creation
- Login to dashboard flow
- Edit and save course

---

## Performance Optimization

### Lazy Loading
- Load courses on-demand
- Paginate video lists (25 per page)
- Infinite scroll for large datasets

### Caching
- Cache course list locally
- Cache user session
- Optimize Firestore queries with indexes

### Image Optimization
- Compress thumbnails before upload
- Use responsive images
- Lazy load images

---

## Accessibility

### WCAG 2.1 AA Compliance
- Keyboard navigation support
- Screen reader friendly
- ARIA labels on all interactive elements
- Color contrast ratios > 4.5:1
- Focus indicators
- Alt text for images

---

## Security Checklist

- [x] HTTPS only
- [x] Password hashing
- [x] CORS configuration
- [x] Firestore security rules
- [x] Input validation
- [x] XSS prevention
- [x] CSRF protection
- [x] Session timeout
- [x] Audit logging
- [x] Rate limiting

---

## Future Enhancements

1. **Multi-language Support**: Localize admin panel
2. **Analytics Dashboard**: View mobile app usage stats
3. **Bulk Operations**: Upload multiple videos at once
4. **Version Control**: Track course changes over time
5. **User Management**: Multiple admin accounts with roles
6. **Video Upload**: Direct video upload to Firebase Storage
7. **AI Descriptions**: Auto-generate video descriptions
8. **Preview Mode**: Preview course as mobile user would see
9. **Scheduling**: Schedule course releases
10. **Notifications**: Push notifications to mobile users

---

**Last Updated**: 2026-02-04
**Version**: 1.0
**Status**: Specification Complete - Ready for Implementation
