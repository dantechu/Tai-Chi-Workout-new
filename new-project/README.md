# Web Admin Panel Project

This folder will contain the Flutter Web admin panel for managing Qigong Workout courses.

---

## Overview

The web admin panel is a **separate Flutter Web project** that connects to the same Firebase Firestore database as the mobile app. It allows administrators to manage courses, sections, and videos through a web interface.

---

## Relationship with Main Project

### Main Project (Parent Folder)
- **Mobile App**: iOS and Android Flutter app
- **Migration Scripts**: Located in `/scripts` directory
- **Purpose**: End-user app for Tai Chi workouts

### This Project (new-project)
- **Web Admin Panel**: Flutter Web application
- **Purpose**: Admin interface to manage course content
- **Shares**: Same Firebase project and Firestore database

---

## Important Notes

### ⚠️ Migration Scripts Location
The migration scripts (`upload_course_data.dart` and `create_admin_user.dart`) are located in the **main project's `/scripts` folder**, NOT in this web panel project.

**Why?**
- Scripts need access to the main app's course data structure
- First-time course upload is done from the main project
- Scripts export JSON files that can be imported to Firestore

**To run migration scripts:**
```bash
# Navigate to main project root (parent folder)
cd ..

# Run the scripts
dart run scripts/upload_course_data.dart
dart run scripts/create_admin_user.dart
```

### 🔄 Data Flow

```
Main Project (Mobile App)
    ├── scripts/upload_course_data.dart → Exports course JSON
    ├── scripts/create_admin_user.dart  → Exports admin user JSON
    └── You manually import to Firestore
                    ↓
            Firebase Firestore
            (courses & users collections)
                    ↓
            ┌───────────────┬──────────────────┐
            ↓               ↓                  ↓
    Mobile App (iOS)  Mobile App (Android)  Web Admin Panel
    (reads courses)   (reads courses)       (reads & writes courses)
```

---

## Getting Started

### Prerequisites
1. ✅ Firebase project created and configured
2. ✅ Course data uploaded to Firestore (using main project scripts)
3. ✅ Admin user created in Firestore (using main project scripts)

### Setup Web Admin Panel

1. **Create Flutter Web Project**
   ```bash
   # Inside this new-project folder
   flutter create qigong_admin_panel
   cd qigong_admin_panel
   ```

2. **Add Firebase Dependencies**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter

     # Firebase
     firebase_core: ^2.24.2
     cloud_firestore: ^4.14.0
     firebase_auth: ^4.16.0

     # State Management
     flutter_bloc: ^8.1.3

     # Routing
     go_router: ^13.0.0

     # Utilities
     intl: ^0.20.2
   ```

3. **Configure Firebase for Web**
   - Go to Firebase Console
   - Copy Web app configuration
   - Add to `web/index.html`

4. **Follow Specifications**
   - Open `web-panel.md` in this folder
   - Follow the complete specifications for building the admin panel
   - Use Material 3 design matching the mobile app theme

---

## Building the Web Admin Panel

### Step 1: Authentication
- Create login page
- Username: `admin`
- Password: `workout2026` (match against Firestore `users` collection)
- Simple session management

### Step 2: Dashboard
- Display course statistics
- Quick actions (Create Course, etc.)
- Recent activity feed

### Step 3: Course Management
- List all courses from Firestore
- Create, edit, delete courses
- Toggle `isActive`, `isDefault`, `isFree` flags

### Step 4: Section & Video Management
- Add/edit/delete sections within courses
- Add/edit/delete videos within sections
- Drag-and-drop reordering

### Step 5: Deploy
```bash
# Build for production
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## Firebase Configuration

### Firestore Collections

**courses** (read/write)
- Course documents with nested sections and videos
- Admin panel can create, read, update, delete

**users** (read only for auth)
- Admin user credentials
- Created by main project scripts
- Admin panel reads for authentication

---

## File Structure

```
new-project/
├── README.md (this file)
├── web-panel.md (complete specifications)
└── qigong_admin_panel/ (Flutter Web project - you'll create this)
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   ├── domain/
    │   ├── data/
    │   └── presentation/
    ├── web/
    ├── pubspec.yaml
    └── firebase.json
```

---

## Development Workflow

### Initial Setup (One Time)
1. In main project: Run migration scripts to upload course data
2. In main project: Manually import JSON to Firestore
3. In new-project: Create Flutter Web project
4. In new-project: Configure Firebase
5. In new-project: Build admin panel following web-panel.md

### Ongoing Development
1. Admin logs into web panel
2. Admin creates/edits/deletes courses, sections, videos
3. Changes are saved to Firestore
4. Mobile app automatically fetches updated data
5. No need to run migration scripts again (unless resetting data)

---

## Testing

### Test Admin Login
- URL: `http://localhost:port` (during development)
- Username: `admin`
- Password: `workout2026`

### Test Course Management
- Create a new test course
- Add sections and videos
- Verify changes appear in Firestore Console
- Verify mobile app can fetch the new course

### Test Mobile App Integration
- Run mobile app
- Navigate to Settings > Courses
- Verify new courses appear
- Select and verify videos load correctly

---

## Deployment

### Firebase Hosting
```bash
# Initialize Firebase Hosting (first time)
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

### Production URL
Your admin panel will be available at:
```
https://[your-project-id].web.app
```

---

## Security

### Authentication
- Simple username/password check against Firestore `users` collection
- Session stored in browser local storage
- Auto-logout after 24 hours

### Firestore Security Rules
Firestore rules ensure:
- Anyone can read courses (for mobile app)
- Only authenticated admins can write to courses
- Only admins can read users collection

---

## Troubleshooting

### "Cannot connect to Firestore"
- Verify Firebase config in `web/index.html`
- Check Firestore security rules
- Ensure Firebase is initialized in `main.dart`

### "Login failed"
- Verify admin user exists in Firestore `users` collection
- Check username/password match
- Review browser console for errors

### "Course not appearing in mobile app"
- Verify `isActive` is set to `true` in Firestore
- Check mobile app is fetching from correct Firestore collection
- Clear mobile app cache and restart

---

## Next Steps

1. **Read web-panel.md** for complete technical specifications
2. **Create Flutter Web project** in this folder
3. **Configure Firebase** for web
4. **Implement authentication** first
5. **Build dashboard** and course management
6. **Test thoroughly** before deploying
7. **Deploy to Firebase Hosting**

---

## Resources

- **Specifications**: See `web-panel.md` in this folder
- **Main Project**: Parent folder (`..`)
- **Migration Scripts**: `../scripts/`
- **Firebase Console**: https://console.firebase.google.com
- **Flutter Web Docs**: https://flutter.dev/web

---

**Last Updated**: 2026-02-04
**Status**: Ready for development
**Admin Credentials**: admin / workout2026

