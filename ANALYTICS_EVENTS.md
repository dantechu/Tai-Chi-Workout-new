# Firebase Analytics Events

This document lists all the Firebase Analytics events tracked in the Tai Chi Workout app.

## Language Selection Events

When a user changes the app language, the following events are logged:

| Language | Event Name |
|----------|-----------|
| English | `english_language_selected` |
| Chinese (简体中文) | `chinese_language_selected` |
| Spanish (Español) | `spanish_language_selected` |
| Japanese (日本語) | `japanese_language_selected` |
| French (Français) | `french_language_selected` |
| German (Deutsch) | `german_language_selected` |
| Korean (한국어) | `korean_language_selected` |

**Event Parameters:**
- `language_code`: The ISO language code (e.g., "en", "zh", "es")
- `timestamp`: ISO 8601 timestamp when the language was selected

**Implementation Location:**
- Service: `lib/core/services/analytics_service.dart`
- Logged from: `lib/presentation/bloc/locale/locale_bloc.dart` (when `ChangeLocale` event is handled)

---

## Premium Events

### Premium Purchase Attempt
**Event:** `premium_purchase_attempt`

Logged when a user taps the purchase button.

**Parameters:**
- `timestamp`: ISO 8601 timestamp

### Premium Purchase Success
**Event:** `premium_purchase_success`

Logged when a premium purchase is completed successfully.

**Parameters:**
- `timestamp`: ISO 8601 timestamp

### Premium Purchase Failed
**Event:** `premium_purchase_failed`

Logged when a premium purchase fails.

**Parameters:**
- `error`: Error message
- `timestamp`: ISO 8601 timestamp

### Premium Restore Attempt
**Event:** `premium_restore_attempt`

Logged when a user attempts to restore previous purchases.

**Parameters:**
- `timestamp`: ISO 8601 timestamp

---

## Video Events

### Video Played
**Event:** `video_played`

Logged when a user starts playing a video.

**Parameters:**
- `video_id`: Unique identifier of the video
- `video_title`: Title of the video
- `timestamp`: ISO 8601 timestamp

### Video Downloaded
**Event:** `video_downloaded`

Logged when a user downloads a video for offline viewing.

**Parameters:**
- `video_id`: Unique identifier of the video
- `video_title`: Title of the video
- `timestamp`: ISO 8601 timestamp

### Video Deleted
**Event:** `video_deleted`

Logged when a user deletes a downloaded video.

**Parameters:**
- `video_id`: Unique identifier of the video
- `video_title`: Title of the video
- `timestamp`: ISO 8601 timestamp

---

## Course Events

### Course Selected
**Event:** `course_selected`

Logged when a user selects a course.

**Parameters:**
- `course_id`: Unique identifier of the course
- `course_name`: Name of the course
- `timestamp`: ISO 8601 timestamp

---

## Practice Events

### Breathing Session Started
**Event:** `breathing_session_started`

Logged when a user starts a breathing exercise session.

**Parameters:**
- `duration_minutes`: Selected duration in minutes
- `timestamp`: ISO 8601 timestamp

### Breathing Session Completed
**Event:** `breathing_session_completed`

Logged when a user completes a breathing exercise session.

**Parameters:**
- `duration_minutes`: Completed duration in minutes
- `timestamp`: ISO 8601 timestamp

---

## Theme Events

### Theme Changed
**Event:** `theme_changed`

Logged when a user changes the app theme.

**Parameters:**
- `theme_mode`: The selected theme mode ("light", "dark", or "system")
- `timestamp`: ISO 8601 timestamp

---

## Music Events

### Music Played
**Event:** `music_played`

Logged when a user plays a music track.

**Parameters:**
- `track_id`: Unique identifier of the track
- `track_title`: Title of the track
- `timestamp`: ISO 8601 timestamp

---

## Screen View Events

Screen views are automatically tracked when navigating between different screens in the app using the `FirebaseAnalyticsObserver`.

---

## How to Use AnalyticsService

The `AnalyticsService` is registered in the dependency injection container and can be accessed via:

```dart
import 'package:get_it/get_it.dart';
import 'package:qigong_workout/core/services/analytics_service.dart';

final analyticsService = GetIt.instance<AnalyticsService>();

// Log a language selection
await analyticsService.logLanguageSelected('en');

// Log a video played event
await analyticsService.logVideoPlayed('video_123', 'Tai Chi Basics');

// Log a custom event
await analyticsService.logEvent(
  name: 'custom_event',
  parameters: {
    'param1': 'value1',
    'param2': 'value2',
  },
);
```

---

## Testing Analytics Events

### In Debug Mode

To view analytics events during development:

1. Enable Firebase Analytics debug mode:
   - **iOS**: Add `-FIRDebugEnabled` to launch arguments in Xcode
   - **Android**: Run `adb shell setprop debug.firebase.analytics.app <package_name>`

2. View events in Firebase Console:
   - Go to Firebase Console > Analytics > DebugView
   - Events will appear in real-time

### In Production

Events will appear in Firebase Console > Analytics > Events after a 24-hour processing period.

---

## Firebase Configuration

Make sure the Firebase configuration files are properly set up:

- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Android**: `android/app/google-services.json`

Firebase Analytics is initialized automatically when the app starts via `firebase_core`.
