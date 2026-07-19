import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing certificate-related data.
///
/// Handles:
/// - User's certificate name (one-time entry, cannot be changed)
/// - Tracking which courses have been completed for certificate generation
class CertificateService {
  static const String _certificateNameKey = 'certificate_user_name';
  static const String _completedCoursesKey = 'certificate_completed_courses';

  static CertificateService? _instance;
  SharedPreferences? _prefs;

  CertificateService._();

  /// Get singleton instance
  static CertificateService get instance {
    _instance ??= CertificateService._();
    return _instance!;
  }

  /// Factory constructor for singleton
  factory CertificateService() => instance;

  /// Initialize the service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if user has already entered their certificate name
  Future<bool> hasEnteredName() async {
    final prefs = await _ensurePrefs();
    final name = prefs.getString(_certificateNameKey);
    return name != null && name.isNotEmpty;
  }

  /// Get the user's certificate name
  Future<String?> getCertificateName() async {
    final prefs = await _ensurePrefs();
    return prefs.getString(_certificateNameKey);
  }

  /// Save the user's certificate name (one-time only)
  /// Returns true if saved successfully, false if name already exists
  Future<bool> saveCertificateName(String name) async {
    final prefs = await _ensurePrefs();

    // Check if name already exists
    final existingName = prefs.getString(_certificateNameKey);
    if (existingName != null && existingName.isNotEmpty) {
      return false; // Name already saved, cannot be changed
    }

    // Save the name
    await prefs.setString(_certificateNameKey, name.trim());
    return true;
  }

  /// Mark a course as completed for certificate purposes
  Future<void> markCourseCompleted(String courseId) async {
    final prefs = await _ensurePrefs();
    final completedCourses = prefs.getStringList(_completedCoursesKey) ?? [];

    if (!completedCourses.contains(courseId)) {
      completedCourses.add(courseId);
      await prefs.setStringList(_completedCoursesKey, completedCourses);
    }
  }

  /// Get list of completed course IDs
  Future<List<String>> getCompletedCourseIds() async {
    final prefs = await _ensurePrefs();
    return prefs.getStringList(_completedCoursesKey) ?? [];
  }

  /// Check if a course has been completed
  Future<bool> isCourseCompleted(String courseId) async {
    final completedCourses = await getCompletedCourseIds();
    return completedCourses.contains(courseId);
  }

  /// Clear all certificate data (for testing purposes only)
  Future<void> clearAll() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_certificateNameKey);
    await prefs.remove(_completedCoursesKey);
  }
}
