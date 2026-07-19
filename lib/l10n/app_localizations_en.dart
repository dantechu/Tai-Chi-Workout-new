// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Excel Mastery';

  @override
  String get home => 'Home';

  @override
  String get videos => 'Videos';

  @override
  String get lessons => 'Lessons';

  @override
  String get practice => 'Practice';

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get courses => 'Courses';

  @override
  String get allLessons => 'All Lessons';

  @override
  String get aboutUs => 'About Us';

  @override
  String get intro => 'Introduction';

  @override
  String get structure => 'Structure';

  @override
  String get flexibility => 'Flexibility';

  @override
  String get fluidity => 'Fluidity';

  @override
  String get power => 'Power';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get download => 'Download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get premiumTitle => 'Unlock Premium';

  @override
  String get premiumSubtitle => 'Get unlimited access to all features';

  @override
  String get premiumFeature1 => 'Offline video downloads';

  @override
  String get premiumFeature2 => 'No advertisements';

  @override
  String get premiumFeature3 => 'Unlock all lessons';

  @override
  String get premiumFeature4 => 'Priority support';

  @override
  String get premiumFeature5 => 'Unlimited access to all courses';

  @override
  String get premiumPrice => '\$4.99';

  @override
  String get purchase => 'Purchase Premium';

  @override
  String get restore => 'Restore Purchases';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get premiumThankYou => 'Thank you for your support!';

  @override
  String get premiumStatusTitle => 'Premium Member';

  @override
  String get premiumStatusSubtitle =>
      'You have unlimited access to all features';

  @override
  String get music => 'Music';

  @override
  String get voiceGuidance => 'Voice Guidance';

  @override
  String get breathing => 'Breathing';

  @override
  String get breathingTimer => 'Breathing Timer';

  @override
  String get duration => 'Duration';

  @override
  String get inhale => 'Inhale';

  @override
  String get exhale => 'Exhale';

  @override
  String get start => 'Start';

  @override
  String get minutes => 'minutes';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get lightThemeDescription => 'Always use light theme';

  @override
  String get dark => 'Dark';

  @override
  String get darkThemeDescription => 'Always use dark theme';

  @override
  String get system => 'System';

  @override
  String get systemThemeDescription => 'Follow system setting';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get spanish => 'Español';

  @override
  String get japanese => '日本語';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get korean => '한국어';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About the App';

  @override
  String get instructor => 'Instructor';

  @override
  String get johnSaxxon => 'Dr Jerry Johnson';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get version => 'Version';

  @override
  String get support => 'Support';

  @override
  String get website => 'Website';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get videoLoadError => 'Failed to load video';

  @override
  String get purchaseError => 'Purchase failed';

  @override
  String get downloadError => 'Download failed';

  @override
  String get search => 'Search';

  @override
  String get searchVideos => 'Search videos...';

  @override
  String get noResults => 'No results found';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloadComplete => 'Download complete';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get downloadPaused => 'Download paused';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Speed';

  @override
  String get quality => 'Quality';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get notification => 'Notification';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get aboutJohnSaxxon => 'About Dr Jerry Johnson';

  @override
  String get johnSaxxonBio =>
      'Our Excel Training Team consists of certified Microsoft Office specialists with over 20 years of experience. They have trained thousands of students worldwide in mastering spreadsheets and data analysis.';

  @override
  String get close => 'Close';

  @override
  String get rateOurApp => 'Rate Our App';

  @override
  String get rateAppMessage =>
      'If you enjoy using Excel Mastery, please take a moment to rate it. Your feedback helps us improve the app for everyone.';

  @override
  String get later => 'Later';

  @override
  String get rateNow => 'Rate Now';

  @override
  String get thankYouRating => 'Thank you! Opening app store...';

  @override
  String video(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
      zero: 'No videos',
    );
    return '$_temp0';
  }

  @override
  String lesson(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String minutes_short(int count) {
    return '${count}m';
  }

  @override
  String seconds_short(int count) {
    return '${count}s';
  }

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get readyForTaiChi => 'Ready to Master Excel?';

  @override
  String get all => 'All';

  @override
  String get tryAdjustingFilter =>
      'Try adjusting your search or category filter';

  @override
  String get premiumFeatureOfflineDescription =>
      'Download videos for offline practice anytime, anywhere';

  @override
  String get premiumFeatureNoAdsDescription =>
      'Enjoy uninterrupted practice sessions without ads';

  @override
  String get premiumFeatureAllLessonsDescription =>
      'Access our complete library of premium lessons';

  @override
  String get premiumFeatureSupportDescription =>
      'Get faster response times for any questions or issues';

  @override
  String get monthlySubscription => 'Monthly Subscription';

  @override
  String get perMonth => 'per month';

  @override
  String get trackPeacefulMorning => 'Peaceful Morning';

  @override
  String get trackFlowingWater => 'Flowing Water';

  @override
  String get trackMountainBreeze => 'Mountain Breeze';

  @override
  String get trackInnerPeace => 'Inner Peace';

  @override
  String get artistTaiChiMasters => 'Excel Experts';

  @override
  String get artistNatureSounds => 'Nature Sounds';

  @override
  String get artistMeditationMusic => 'Meditation Music';

  @override
  String get artistZenCollection => 'Zen Collection';

  @override
  String get artistAmbientMeditation => 'Ambient Meditation';

  @override
  String get artistDeepRelaxation => 'Deep Relaxation';

  @override
  String get artistNewAgeZen => 'New Age Zen';

  @override
  String get artistMeditationSounds => 'Meditation Sounds';

  @override
  String get playlist => 'Playlist';

  @override
  String get hold => 'Hold';

  @override
  String get breathe => 'Breathe';

  @override
  String get min => 'min';

  @override
  String get wellDone => '🎉 Well Done!';

  @override
  String get breathingSessionComplete =>
      'You have completed your breathing session. Take a moment to notice how you feel.';

  @override
  String holdSeconds(int seconds) {
    return 'Hold ${seconds}s';
  }

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get premiumSubscriptionRequired =>
      'Premium subscription required to watch this video';

  @override
  String get videoPlaybackError => 'Video playback error';

  @override
  String get share => 'Share';

  @override
  String get report => 'Report';

  @override
  String get getPremium => 'Get Premium';

  @override
  String get videoPlayerNotAvailable => 'Video player not available';

  @override
  String get description => 'Description';

  @override
  String get defaultVideoDescription =>
      'Master Excel with this comprehensive lesson. Learn essential formulas, data analysis techniques, and productivity tips that will enhance your spreadsheet skills.';

  @override
  String get premiumContent => 'Premium Content';

  @override
  String get premiumContentDescription =>
      'This is exclusive premium content for subscribers.';

  @override
  String get downloadVideo => 'Download Video';

  @override
  String get downloadVideoConfirmation =>
      'Download this video for offline viewing?';

  @override
  String get pro => 'PRO';

  @override
  String get premiumRequired => 'Premium Required';

  @override
  String get initializationError => 'Initialization Error';

  @override
  String get initializationErrorMessage =>
      'Failed to initialize the app. Please check your internet connection and try again.';

  @override
  String get appTagline => 'Master Spreadsheets Step by Step';

  @override
  String get noInternetNoCachedData =>
      'No internet connection and no cached data';

  @override
  String get noInternetNoCachedLessons =>
      'No internet connection and no cached data';

  @override
  String get videoNotFoundOffline =>
      'Video not found locally and no internet connection';

  @override
  String get lessonNotFoundOffline =>
      'Lesson not found locally and no internet connection';

  @override
  String get noVideosFoundForCategory =>
      'No videos found for category and no internet connection';

  @override
  String get storeNotAvailable => 'Store not available';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get breathingExercise => 'Breathing Exercise';

  @override
  String get findYourCalm =>
      'Find your calm with guided breathing. Select your session duration and let\'s begin.';

  @override
  String get startBreathing => 'Start Breathing';

  @override
  String get breathingSession => 'Breathing Session';

  @override
  String get endSession => 'End';

  @override
  String get resume => 'Resume';

  @override
  String get breatheInSlowly => 'Breathe in slowly and deeply';

  @override
  String get holdYourBreath => 'Hold your breath gently';

  @override
  String get exhaleSlowly => 'Exhale slowly and completely';

  @override
  String get refreshCourses => 'Refresh courses';

  @override
  String get courseSelected => 'selected';

  @override
  String get errorLoadingCourses => 'Error Loading Courses';

  @override
  String get noCoursesAvailable => 'No Courses Available';

  @override
  String get checkBackLater => 'Check back later for new courses';

  @override
  String get courseDetails => 'Course Details';

  @override
  String get currentlySelected => 'Currently Selected';

  @override
  String get sections => 'Sections';

  @override
  String get free => 'Free';

  @override
  String get defaultBadge => 'Default';

  @override
  String get aboutThisCourse => 'About This Course';

  @override
  String get viewMore => 'View more';

  @override
  String get viewLess => 'View less';

  @override
  String get courseContent => 'Course Content';

  @override
  String videosCount(int count) {
    return '$count videos';
  }

  @override
  String get selected => 'Selected';

  @override
  String get selectThisCourse => 'Select This Course';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterAllTime => 'All Time';

  @override
  String get currentCourse => 'Current Course';

  @override
  String get currentCourseProgress => 'Current Course Progress';

  @override
  String get selectCourseToSeeProgress => 'Select a course to see progress';

  @override
  String get done => 'Done!';

  @override
  String get complete => 'Complete';

  @override
  String get totalTime => 'Total Time';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get noActivityThisWeek => 'No activity this week';

  @override
  String get lessonTypeVideo => 'Video';

  @override
  String get lessonTypeAudio => 'Audio';

  @override
  String get lessonTypeText => 'Text';

  @override
  String get lessonTypeQuiz => 'Quiz';

  @override
  String get lessonTypeFlashcards => 'Flashcards';

  @override
  String get byLessonType => 'By Lesson Type';

  @override
  String get lessonBreakdown => 'Lesson Breakdown';

  @override
  String get completeLessonsToSeeBreakdown =>
      'Complete lessons to see breakdown';

  @override
  String get courseProgress => 'Course Progress';

  @override
  String get yourCourses => 'Your Courses';

  @override
  String get allCourses => 'All Courses';

  @override
  String get quizzesAccuracy => 'Quizzes Accuracy';

  @override
  String get flashcardsAccuracy => 'Flashcards Accuracy';

  @override
  String get average => 'Average';

  @override
  String get best => 'Best';

  @override
  String completedCount(int completed, int total) {
    return '$completed/$total completed';
  }

  @override
  String get noVideoUrlAvailable => 'No video URL available';

  @override
  String get noAudioUrlAvailable => 'No audio URL available';

  @override
  String get noContentAvailable => 'No content available';

  @override
  String get noQuestionsAvailable => 'No questions available';

  @override
  String get noFlashcardsAvailable => 'No flashcards available';

  @override
  String get lessonTypeArticle => 'Article';

  @override
  String get minRead => 'min read';

  @override
  String nQuestions(int count) {
    return '$count questions';
  }

  @override
  String nCards(int count) {
    return '$count cards';
  }

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get completed => 'Completed';

  @override
  String get lessonMarkedComplete => 'Lesson marked as complete!';

  @override
  String get noQuestionsForQuiz => 'No questions available for this quiz.';

  @override
  String questionXOfY(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get seeResults => 'See Results';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get keepPracticing => 'Keep Practicing!';

  @override
  String youScoredPercent(int score) {
    return 'You scored $score%';
  }

  @override
  String xOutOfYCorrect(int correct, int total) {
    return '$correct out of $total correct';
  }

  @override
  String passingScorePercent(int score) {
    return 'Passing score: $score%';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get backToLessons => 'Back to Lessons';

  @override
  String get noFlashcardsAvailableMessage => 'No flashcards available.';

  @override
  String cardXOfY(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String get tapToReveal => 'Tap to reveal';

  @override
  String get tapToFlipBack => 'Tap to flip back';

  @override
  String get front => 'FRONT';

  @override
  String get back => 'BACK';

  @override
  String get showAnswer => 'Show Answer';

  @override
  String get again => 'Again';

  @override
  String get hard => 'Hard';

  @override
  String get good => 'Good';

  @override
  String get easy => 'Easy';

  @override
  String get greatJob => 'Great Job!';

  @override
  String get studyAgain => 'Study Again';

  @override
  String xCorrectYWrong(int correct, int wrong) {
    return '$correct correct, $wrong wrong';
  }

  @override
  String get lifetimeAccess => 'Lifetime Access';

  @override
  String get oneTimePayment => 'One-time payment';

  @override
  String get lessonCompleted => 'Lesson Completed!';

  @override
  String get wouldYouLikeToContinue =>
      'Would you like to continue to the next lesson?';

  @override
  String get nextLesson => 'Next Lesson';

  @override
  String get courseCompleted => 'Course Completed!';

  @override
  String get youHaveCompletedCourse =>
      'You have completed all lessons in this course.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get continueToNextLesson => 'Continue to Next Lesson';

  @override
  String youCompletedLesson(String lessonTitle) {
    return 'You completed: $lessonTitle';
  }

  @override
  String get amazingProgress => 'Amazing progress! Keep learning!';

  @override
  String get celebrateCourseComplete =>
      'You\'ve mastered this course. Celebrate your achievement!';

  @override
  String get premiumLesson => 'Premium Lesson';

  @override
  String get unlockToAccess => 'Unlock this lesson to continue learning';

  @override
  String get watchAdToUnlock => 'Watch Ad to Unlock';

  @override
  String remainingUnlocksToday(int count) {
    return '$count free unlocks remaining today';
  }

  @override
  String get or => 'or';

  @override
  String get dailyLimitReached =>
      'Daily free unlock limit reached. Upgrade to Pro for unlimited access!';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get adNotReady => 'Ad not ready. Please try again.';

  @override
  String get streak => 'Streak';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get streakAtRisk => 'Complete a lesson today!';

  @override
  String get pace => 'Pace';

  @override
  String get lessonPerDay => 'lesson/day';

  @override
  String get lessonsPerDay => 'lessons/day';

  @override
  String get allTime => 'All time';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get averageTimePerType => 'Average Time Per Type';

  @override
  String get timePerLesson => 'Time per Lesson';

  @override
  String nLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String get accelerating => 'Accelerating';

  @override
  String get steady => 'Steady';

  @override
  String get slowing => 'Slowing';
}
