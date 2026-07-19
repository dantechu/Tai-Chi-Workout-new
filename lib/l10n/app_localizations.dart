import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Excel Mastery'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @statisticsTab.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTab;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @allLessons.
  ///
  /// In en, this message translates to:
  /// **'All Lessons'**
  String get allLessons;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get intro;

  /// No description provided for @structure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structure;

  /// No description provided for @flexibility.
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get flexibility;

  /// No description provided for @fluidity.
  ///
  /// In en, this message translates to:
  /// **'Fluidity'**
  String get fluidity;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to all features'**
  String get premiumSubtitle;

  /// No description provided for @premiumFeature1.
  ///
  /// In en, this message translates to:
  /// **'Offline video downloads'**
  String get premiumFeature1;

  /// No description provided for @premiumFeature2.
  ///
  /// In en, this message translates to:
  /// **'No advertisements'**
  String get premiumFeature2;

  /// No description provided for @premiumFeature3.
  ///
  /// In en, this message translates to:
  /// **'Unlock all lessons'**
  String get premiumFeature3;

  /// No description provided for @premiumFeature4.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumFeature4;

  /// No description provided for @premiumFeature5.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all courses'**
  String get premiumFeature5;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'\$4.99'**
  String get premiumPrice;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase Premium'**
  String get purchase;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @premiumThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get premiumThankYou;

  /// No description provided for @premiumStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumStatusTitle;

  /// No description provided for @premiumStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have unlimited access to all features'**
  String get premiumStatusSubtitle;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @voiceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Voice Guidance'**
  String get voiceGuidance;

  /// No description provided for @breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// No description provided for @breathingTimer.
  ///
  /// In en, this message translates to:
  /// **'Breathing Timer'**
  String get breathingTimer;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get lightThemeDescription;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get darkThemeDescription;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @systemThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get systemThemeDescription;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @johnSaxxon.
  ///
  /// In en, this message translates to:
  /// **'Dr Jerry Johnson'**
  String get johnSaxxon;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @videoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get videoLoadError;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseError;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadError;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchVideos.
  ///
  /// In en, this message translates to:
  /// **'Search videos...'**
  String get searchVideos;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Download paused'**
  String get downloadPaused;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @aboutJohnSaxxon.
  ///
  /// In en, this message translates to:
  /// **'About Dr Jerry Johnson'**
  String get aboutJohnSaxxon;

  /// No description provided for @johnSaxxonBio.
  ///
  /// In en, this message translates to:
  /// **'Our Excel Training Team consists of certified Microsoft Office specialists with over 20 years of experience. They have trained thousands of students worldwide in mastering spreadsheets and data analysis.'**
  String get johnSaxxonBio;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @rateOurApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Our App'**
  String get rateOurApp;

  /// No description provided for @rateAppMessage.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy using Excel Mastery, please take a moment to rate it. Your feedback helps us improve the app for everyone.'**
  String get rateAppMessage;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @thankYouRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Opening app store...'**
  String get thankYouRating;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No videos} =1{1 video} other{{count} videos}}'**
  String video(int count);

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lessons} =1{1 lesson} other{{count} lessons}}'**
  String lesson(int count);

  /// No description provided for @minutes_short.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutes_short(int count);

  /// No description provided for @seconds_short.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String seconds_short(int count);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// No description provided for @readyForTaiChi.
  ///
  /// In en, this message translates to:
  /// **'Ready to Master Excel?'**
  String get readyForTaiChi;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @tryAdjustingFilter.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or category filter'**
  String get tryAdjustingFilter;

  /// No description provided for @premiumFeatureOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Download videos for offline practice anytime, anywhere'**
  String get premiumFeatureOfflineDescription;

  /// No description provided for @premiumFeatureNoAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enjoy uninterrupted practice sessions without ads'**
  String get premiumFeatureNoAdsDescription;

  /// No description provided for @premiumFeatureAllLessonsDescription.
  ///
  /// In en, this message translates to:
  /// **'Access our complete library of premium lessons'**
  String get premiumFeatureAllLessonsDescription;

  /// No description provided for @premiumFeatureSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Get faster response times for any questions or issues'**
  String get premiumFeatureSupportDescription;

  /// No description provided for @monthlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get monthlySubscription;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @trackPeacefulMorning.
  ///
  /// In en, this message translates to:
  /// **'Peaceful Morning'**
  String get trackPeacefulMorning;

  /// No description provided for @trackFlowingWater.
  ///
  /// In en, this message translates to:
  /// **'Flowing Water'**
  String get trackFlowingWater;

  /// No description provided for @trackMountainBreeze.
  ///
  /// In en, this message translates to:
  /// **'Mountain Breeze'**
  String get trackMountainBreeze;

  /// No description provided for @trackInnerPeace.
  ///
  /// In en, this message translates to:
  /// **'Inner Peace'**
  String get trackInnerPeace;

  /// No description provided for @artistTaiChiMasters.
  ///
  /// In en, this message translates to:
  /// **'Excel Experts'**
  String get artistTaiChiMasters;

  /// No description provided for @artistNatureSounds.
  ///
  /// In en, this message translates to:
  /// **'Nature Sounds'**
  String get artistNatureSounds;

  /// No description provided for @artistMeditationMusic.
  ///
  /// In en, this message translates to:
  /// **'Meditation Music'**
  String get artistMeditationMusic;

  /// No description provided for @artistZenCollection.
  ///
  /// In en, this message translates to:
  /// **'Zen Collection'**
  String get artistZenCollection;

  /// No description provided for @artistAmbientMeditation.
  ///
  /// In en, this message translates to:
  /// **'Ambient Meditation'**
  String get artistAmbientMeditation;

  /// No description provided for @artistDeepRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Deep Relaxation'**
  String get artistDeepRelaxation;

  /// No description provided for @artistNewAgeZen.
  ///
  /// In en, this message translates to:
  /// **'New Age Zen'**
  String get artistNewAgeZen;

  /// No description provided for @artistMeditationSounds.
  ///
  /// In en, this message translates to:
  /// **'Meditation Sounds'**
  String get artistMeditationSounds;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @breathe.
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get breathe;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'🎉 Well Done!'**
  String get wellDone;

  /// No description provided for @breathingSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'You have completed your breathing session. Take a moment to notice how you feel.'**
  String get breathingSessionComplete;

  /// No description provided for @holdSeconds.
  ///
  /// In en, this message translates to:
  /// **'Hold {seconds}s'**
  String holdSeconds(int seconds);

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// No description provided for @premiumSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription required to watch this video'**
  String get premiumSubscriptionRequired;

  /// No description provided for @videoPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'Video playback error'**
  String get videoPlaybackError;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @getPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremium;

  /// No description provided for @videoPlayerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video player not available'**
  String get videoPlayerNotAvailable;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @defaultVideoDescription.
  ///
  /// In en, this message translates to:
  /// **'Master Excel with this comprehensive lesson. Learn essential formulas, data analysis techniques, and productivity tips that will enhance your spreadsheet skills.'**
  String get defaultVideoDescription;

  /// No description provided for @premiumContent.
  ///
  /// In en, this message translates to:
  /// **'Premium Content'**
  String get premiumContent;

  /// No description provided for @premiumContentDescription.
  ///
  /// In en, this message translates to:
  /// **'This is exclusive premium content for subscribers.'**
  String get premiumContentDescription;

  /// No description provided for @downloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download Video'**
  String get downloadVideo;

  /// No description provided for @downloadVideoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Download this video for offline viewing?'**
  String get downloadVideoConfirmation;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premiumRequired;

  /// No description provided for @initializationError.
  ///
  /// In en, this message translates to:
  /// **'Initialization Error'**
  String get initializationError;

  /// No description provided for @initializationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize the app. Please check your internet connection and try again.'**
  String get initializationErrorMessage;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Master Spreadsheets Step by Step'**
  String get appTagline;

  /// No description provided for @noInternetNoCachedData.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and no cached data'**
  String get noInternetNoCachedData;

  /// No description provided for @noInternetNoCachedLessons.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and no cached data'**
  String get noInternetNoCachedLessons;

  /// No description provided for @videoNotFoundOffline.
  ///
  /// In en, this message translates to:
  /// **'Video not found locally and no internet connection'**
  String get videoNotFoundOffline;

  /// No description provided for @lessonNotFoundOffline.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found locally and no internet connection'**
  String get lessonNotFoundOffline;

  /// No description provided for @noVideosFoundForCategory.
  ///
  /// In en, this message translates to:
  /// **'No videos found for category and no internet connection'**
  String get noVideosFoundForCategory;

  /// No description provided for @storeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Store not available'**
  String get storeNotAvailable;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @breathingExercise.
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercise'**
  String get breathingExercise;

  /// No description provided for @findYourCalm.
  ///
  /// In en, this message translates to:
  /// **'Find your calm with guided breathing. Select your session duration and let\'s begin.'**
  String get findYourCalm;

  /// No description provided for @startBreathing.
  ///
  /// In en, this message translates to:
  /// **'Start Breathing'**
  String get startBreathing;

  /// No description provided for @breathingSession.
  ///
  /// In en, this message translates to:
  /// **'Breathing Session'**
  String get breathingSession;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endSession;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @breatheInSlowly.
  ///
  /// In en, this message translates to:
  /// **'Breathe in slowly and deeply'**
  String get breatheInSlowly;

  /// No description provided for @holdYourBreath.
  ///
  /// In en, this message translates to:
  /// **'Hold your breath gently'**
  String get holdYourBreath;

  /// No description provided for @exhaleSlowly.
  ///
  /// In en, this message translates to:
  /// **'Exhale slowly and completely'**
  String get exhaleSlowly;

  /// No description provided for @refreshCourses.
  ///
  /// In en, this message translates to:
  /// **'Refresh courses'**
  String get refreshCourses;

  /// No description provided for @courseSelected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get courseSelected;

  /// No description provided for @errorLoadingCourses.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Courses'**
  String get errorLoadingCourses;

  /// No description provided for @noCoursesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Courses Available'**
  String get noCoursesAvailable;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new courses'**
  String get checkBackLater;

  /// No description provided for @courseDetails.
  ///
  /// In en, this message translates to:
  /// **'Course Details'**
  String get courseDetails;

  /// No description provided for @currentlySelected.
  ///
  /// In en, this message translates to:
  /// **'Currently Selected'**
  String get currentlySelected;

  /// No description provided for @sections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get sections;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBadge;

  /// No description provided for @aboutThisCourse.
  ///
  /// In en, this message translates to:
  /// **'About This Course'**
  String get aboutThisCourse;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'View less'**
  String get viewLess;

  /// No description provided for @courseContent.
  ///
  /// In en, this message translates to:
  /// **'Course Content'**
  String get courseContent;

  /// No description provided for @videosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} videos'**
  String videosCount(int count);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @selectThisCourse.
  ///
  /// In en, this message translates to:
  /// **'Select This Course'**
  String get selectThisCourse;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterThisMonth;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAllTime;

  /// No description provided for @currentCourse.
  ///
  /// In en, this message translates to:
  /// **'Current Course'**
  String get currentCourse;

  /// No description provided for @currentCourseProgress.
  ///
  /// In en, this message translates to:
  /// **'Current Course Progress'**
  String get currentCourseProgress;

  /// No description provided for @selectCourseToSeeProgress.
  ///
  /// In en, this message translates to:
  /// **'Select a course to see progress'**
  String get selectCourseToSeeProgress;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get done;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @noActivityThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No activity this week'**
  String get noActivityThisWeek;

  /// No description provided for @lessonTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get lessonTypeVideo;

  /// No description provided for @lessonTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get lessonTypeAudio;

  /// No description provided for @lessonTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get lessonTypeText;

  /// No description provided for @lessonTypeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get lessonTypeQuiz;

  /// No description provided for @lessonTypeFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get lessonTypeFlashcards;

  /// No description provided for @byLessonType.
  ///
  /// In en, this message translates to:
  /// **'By Lesson Type'**
  String get byLessonType;

  /// No description provided for @lessonBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Lesson Breakdown'**
  String get lessonBreakdown;

  /// No description provided for @completeLessonsToSeeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Complete lessons to see breakdown'**
  String get completeLessonsToSeeBreakdown;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course Progress'**
  String get courseProgress;

  /// No description provided for @yourCourses.
  ///
  /// In en, this message translates to:
  /// **'Your Courses'**
  String get yourCourses;

  /// No description provided for @allCourses.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get allCourses;

  /// No description provided for @quizzesAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Accuracy'**
  String get quizzesAccuracy;

  /// No description provided for @flashcardsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Flashcards Accuracy'**
  String get flashcardsAccuracy;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String completedCount(int completed, int total);

  /// No description provided for @noVideoUrlAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video URL available'**
  String get noVideoUrlAvailable;

  /// No description provided for @noAudioUrlAvailable.
  ///
  /// In en, this message translates to:
  /// **'No audio URL available'**
  String get noAudioUrlAvailable;

  /// No description provided for @noContentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No content available'**
  String get noContentAvailable;

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestionsAvailable;

  /// No description provided for @noFlashcardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No flashcards available'**
  String get noFlashcardsAvailable;

  /// No description provided for @lessonTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get lessonTypeArticle;

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'min read'**
  String get minRead;

  /// No description provided for @nQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String nQuestions(int count);

  /// No description provided for @nCards.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String nCards(int count);

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @lessonMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'Lesson marked as complete!'**
  String get lessonMarkedComplete;

  /// No description provided for @noQuestionsForQuiz.
  ///
  /// In en, this message translates to:
  /// **'No questions available for this quiz.'**
  String get noQuestionsForQuiz;

  /// No description provided for @questionXOfY.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionXOfY(int current, int total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @keepPracticing.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get keepPracticing;

  /// No description provided for @youScoredPercent.
  ///
  /// In en, this message translates to:
  /// **'You scored {score}%'**
  String youScoredPercent(int score);

  /// No description provided for @xOutOfYCorrect.
  ///
  /// In en, this message translates to:
  /// **'{correct} out of {total} correct'**
  String xOutOfYCorrect(int correct, int total);

  /// No description provided for @passingScorePercent.
  ///
  /// In en, this message translates to:
  /// **'Passing score: {score}%'**
  String passingScorePercent(int score);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @backToLessons.
  ///
  /// In en, this message translates to:
  /// **'Back to Lessons'**
  String get backToLessons;

  /// No description provided for @noFlashcardsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No flashcards available.'**
  String get noFlashcardsAvailableMessage;

  /// No description provided for @cardXOfY.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String cardXOfY(int current, int total);

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToReveal;

  /// No description provided for @tapToFlipBack.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip back'**
  String get tapToFlipBack;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'FRONT'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get back;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// No description provided for @studyAgain.
  ///
  /// In en, this message translates to:
  /// **'Study Again'**
  String get studyAgain;

  /// No description provided for @xCorrectYWrong.
  ///
  /// In en, this message translates to:
  /// **'{correct} correct, {wrong} wrong'**
  String xCorrectYWrong(int correct, int wrong);

  /// No description provided for @lifetimeAccess.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get lifetimeAccess;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment'**
  String get oneTimePayment;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lesson Completed!'**
  String get lessonCompleted;

  /// No description provided for @wouldYouLikeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Would you like to continue to the next lesson?'**
  String get wouldYouLikeToContinue;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLesson;

  /// No description provided for @courseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Course Completed!'**
  String get courseCompleted;

  /// No description provided for @youHaveCompletedCourse.
  ///
  /// In en, this message translates to:
  /// **'You have completed all lessons in this course.'**
  String get youHaveCompletedCourse;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @continueToNextLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue to Next Lesson'**
  String get continueToNextLesson;

  /// No description provided for @youCompletedLesson.
  ///
  /// In en, this message translates to:
  /// **'You completed: {lessonTitle}'**
  String youCompletedLesson(String lessonTitle);

  /// No description provided for @amazingProgress.
  ///
  /// In en, this message translates to:
  /// **'Amazing progress! Keep learning!'**
  String get amazingProgress;

  /// No description provided for @celebrateCourseComplete.
  ///
  /// In en, this message translates to:
  /// **'You\'ve mastered this course. Celebrate your achievement!'**
  String get celebrateCourseComplete;

  /// No description provided for @premiumLesson.
  ///
  /// In en, this message translates to:
  /// **'Premium Lesson'**
  String get premiumLesson;

  /// No description provided for @unlockToAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlock this lesson to continue learning'**
  String get unlockToAccess;

  /// No description provided for @watchAdToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad to Unlock'**
  String get watchAdToUnlock;

  /// No description provided for @remainingUnlocksToday.
  ///
  /// In en, this message translates to:
  /// **'{count} free unlocks remaining today'**
  String remainingUnlocksToday(int count);

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily free unlock limit reached. Upgrade to Pro for unlimited access!'**
  String get dailyLimitReached;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad not ready. Please try again.'**
  String get adNotReady;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @streakAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Complete a lesson today!'**
  String get streakAtRisk;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @lessonPerDay.
  ///
  /// In en, this message translates to:
  /// **'lesson/day'**
  String get lessonPerDay;

  /// No description provided for @lessonsPerDay.
  ///
  /// In en, this message translates to:
  /// **'lessons/day'**
  String get lessonsPerDay;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @averageTimePerType.
  ///
  /// In en, this message translates to:
  /// **'Average Time Per Type'**
  String get averageTimePerType;

  /// No description provided for @timePerLesson.
  ///
  /// In en, this message translates to:
  /// **'Time per Lesson'**
  String get timePerLesson;

  /// No description provided for @nLessons.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String nLessons(int count);

  /// No description provided for @accelerating.
  ///
  /// In en, this message translates to:
  /// **'Accelerating'**
  String get accelerating;

  /// No description provided for @steady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get steady;

  /// No description provided for @slowing.
  ///
  /// In en, this message translates to:
  /// **'Slowing'**
  String get slowing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
