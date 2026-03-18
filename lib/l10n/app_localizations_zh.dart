// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '太极健身';

  @override
  String get home => '首页';

  @override
  String get videos => '视频';

  @override
  String get practice => '练习';

  @override
  String get settings => '设置';

  @override
  String get premium => '高级版';

  @override
  String get allLessons => '所有课程';

  @override
  String get aboutUs => '关于我们';

  @override
  String get intro => '介绍';

  @override
  String get structure => '结构';

  @override
  String get flexibility => '柔韧性';

  @override
  String get fluidity => '流畅性';

  @override
  String get power => '力量';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get stop => '停止';

  @override
  String get download => '下载';

  @override
  String get downloaded => '已下载';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get premiumTitle => '解锁高级版';

  @override
  String get premiumSubtitle => '获得所有功能的无限访问权限';

  @override
  String get premiumFeature1 => '离线视频下载';

  @override
  String get premiumFeature2 => '无广告';

  @override
  String get premiumFeature3 => '解锁所有课程';

  @override
  String get premiumFeature4 => '优先支持';

  @override
  String get premiumFeature5 => '无限访问所有课程';

  @override
  String get premiumPrice => '\$4.99';

  @override
  String get purchase => '购买高级版';

  @override
  String get restore => '恢复购买';

  @override
  String get premiumActive => '高级版已激活';

  @override
  String get premiumThankYou => '谢谢您的支持！';

  @override
  String get premiumStatusTitle => '高级会员';

  @override
  String get premiumStatusSubtitle => '您可以无限访问所有功能';

  @override
  String get music => '音乐';

  @override
  String get voiceGuidance => '语音指导';

  @override
  String get breathing => '呼吸';

  @override
  String get breathingTimer => '呼吸计时器';

  @override
  String get duration => '时长';

  @override
  String get inhale => '吸气';

  @override
  String get exhale => '呼气';

  @override
  String get start => '开始';

  @override
  String get minutes => '分钟';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get lightThemeDescription => '始终使用浅色主题';

  @override
  String get dark => '深色';

  @override
  String get darkThemeDescription => '始终使用深色主题';

  @override
  String get system => '系统';

  @override
  String get systemThemeDescription => '跟随系统设置';

  @override
  String get appearance => '外观';

  @override
  String get language => '语言';

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
  String get about => '关于';

  @override
  String get aboutApp => '关于应用';

  @override
  String get instructor => '教练';

  @override
  String get johnSaxxon => '约翰·萨克逊';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get contactUs => '联系我们';

  @override
  String get rateApp => '评价应用';

  @override
  String get version => '版本';

  @override
  String get support => '支持';

  @override
  String get website => '网站';

  @override
  String get error => '错误';

  @override
  String get loading => '加载中...';

  @override
  String get noInternet => '无网络连接';

  @override
  String get somethingWentWrong => '出现了问题';

  @override
  String get videoLoadError => '视频加载失败';

  @override
  String get purchaseError => '购买失败';

  @override
  String get downloadError => '下载失败';

  @override
  String get search => '搜索';

  @override
  String get searchVideos => '搜索视频...';

  @override
  String get noResults => '未找到结果';

  @override
  String get filter => '筛选';

  @override
  String get sort => '排序';

  @override
  String get downloading => '下载中';

  @override
  String get downloadComplete => '下载完成';

  @override
  String get downloadFailed => '下载失败';

  @override
  String get downloadPaused => '下载暂停';

  @override
  String get volume => '音量';

  @override
  String get speed => '速度';

  @override
  String get quality => '质量';

  @override
  String get subtitles => '字幕';

  @override
  String get fullscreen => '全屏';

  @override
  String get notification => '通知';

  @override
  String get notificationsEnabled => '通知已启用';

  @override
  String get notificationsDisabled => '通知已禁用';

  @override
  String get aboutJohnSaxxon => '关于约翰·萨克逊';

  @override
  String get johnSaxxonBio =>
      '约翰·萨克逊是一位经过认证的太极教练，拥有超过20年的经验。他已经在世界各地培训了数千名学生学习太极和冥想的艺术。';

  @override
  String get close => '关闭';

  @override
  String get rateOurApp => '评价我们的应用';

  @override
  String get rateAppMessage => '如果您喜欢使用我们的太极应用，请花一点时间给它评分。您的反馈帮助我们为每个人改进应用。';

  @override
  String get later => '稍后';

  @override
  String get rateNow => '立即评价';

  @override
  String get thankYouRating => '谢谢您！正在打开应用商店...';

  @override
  String video(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个视频',
      one: '1个视频',
      zero: '没有视频',
    );
    return '$_temp0';
  }

  @override
  String lesson(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count节课程',
      one: '1节课程',
      zero: '没有课程',
    );
    return '$_temp0';
  }

  @override
  String minutes_short(int count) {
    return '$count分';
  }

  @override
  String seconds_short(int count) {
    return '$count秒';
  }

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get goodNight => '晚安';

  @override
  String get readyForTaiChi => '准备好练太极了吗？';

  @override
  String get all => '全部';

  @override
  String get tryAdjustingFilter => '尝试调整您的搜索或分类筛选';

  @override
  String get premiumFeatureOfflineDescription => '随时随地下载视频进行离线练习';

  @override
  String get premiumFeatureNoAdsDescription => '享受不间断的练习时间，无广告干扰';

  @override
  String get premiumFeatureAllLessonsDescription => '访问我们完整的高级课程库';

  @override
  String get premiumFeatureSupportDescription => '获得更快的响应时间以解答任何问题或问题';

  @override
  String get monthlySubscription => '月度订阅';

  @override
  String get perMonth => '每月';

  @override
  String get trackPeacefulMorning => '宁静晨光';

  @override
  String get trackFlowingWater => '流水潺潺';

  @override
  String get trackMountainBreeze => '山间微风';

  @override
  String get trackInnerPeace => '内心平静';

  @override
  String get artistTaiChiMasters => '太极大师';

  @override
  String get artistNatureSounds => '自然音响';

  @override
  String get artistMeditationMusic => '冥想音乐';

  @override
  String get artistZenCollection => '禅意合集';

  @override
  String get artistAmbientMeditation => '环境冥想';

  @override
  String get artistDeepRelaxation => '深度放松';

  @override
  String get artistNewAgeZen => '新时代禅';

  @override
  String get artistMeditationSounds => '冥想音响';

  @override
  String get playlist => '播放列表';

  @override
  String get hold => '保持';

  @override
  String get breathe => '呼吸';

  @override
  String get min => '分钟';

  @override
  String get wellDone => '🎉 很棒！';

  @override
  String get breathingSessionComplete => '您已完成呼吸练习。花点时间感受一下您现在的感觉。';

  @override
  String holdSeconds(int seconds) {
    return '保持$seconds秒';
  }

  @override
  String get selectDuration => '选择时长';

  @override
  String get premiumSubscriptionRequired => '观看此视频需要高级版订阅';

  @override
  String get videoPlaybackError => '视频播放错误';

  @override
  String get share => '分享';

  @override
  String get report => '举报';

  @override
  String get getPremium => '获取高级版';

  @override
  String get videoPlayerNotAvailable => '视频播放器不可用';

  @override
  String get description => '描述';

  @override
  String get defaultVideoDescription =>
      '通过这个综合课程掌握太极的艺术。学习正确的姿势、呼吸技巧和流畅的动作，这将提升您的练习水平。';

  @override
  String get premiumContent => '高级内容';

  @override
  String get premiumContentDescription => '这是订阅者专享的高级内容。';

  @override
  String get downloadVideo => '下载视频';

  @override
  String get downloadVideoConfirmation => '下载此视频以供离线观看？';

  @override
  String get pro => 'PRO';

  @override
  String get premiumRequired => '需要高级版';

  @override
  String get initializationError => '初始化错误';

  @override
  String get initializationErrorMessage => '应用程序初始化失败。请检查您的网络连接并重试。';

  @override
  String get appTagline => '掌握太极艺术';

  @override
  String get noInternetNoCachedData => '无网络连接且无缓存数据';

  @override
  String get noInternetNoCachedLessons => '无网络连接且无缓存数据';

  @override
  String get videoNotFoundOffline => '本地未找到视频且无网络连接';

  @override
  String get lessonNotFoundOffline => '本地未找到课程且无网络连接';

  @override
  String get noVideosFoundForCategory => '该分类下未找到视频且无网络连接';

  @override
  String get storeNotAvailable => '商店不可用';

  @override
  String get productNotFound => '未找到产品';

  @override
  String get breathingExercise => '呼吸练习';

  @override
  String get findYourCalm => '通过引导呼吸找到你的宁静。选择你的练习时长，让我们开始吧。';

  @override
  String get startBreathing => '开始呼吸';

  @override
  String get breathingSession => '呼吸练习';

  @override
  String get endSession => '结束';

  @override
  String get resume => '继续';

  @override
  String get breatheInSlowly => '缓慢深呼吸';

  @override
  String get holdYourBreath => '轻柔地屏住呼吸';

  @override
  String get exhaleSlowly => '缓慢完全地呼气';

  @override
  String get courses => '课程';

  @override
  String get refreshCourses => '刷新课程';

  @override
  String get courseSelected => '已选择';

  @override
  String get errorLoadingCourses => '课程加载错误';

  @override
  String get noCoursesAvailable => '暂无课程';

  @override
  String get checkBackLater => '稍后回来查看新课程';

  @override
  String get courseDetails => '课程详情';

  @override
  String get currentlySelected => '当前选择';

  @override
  String get sections => '部分';

  @override
  String get free => '免费';

  @override
  String get defaultBadge => '默认';

  @override
  String get aboutThisCourse => '关于本课程';

  @override
  String get viewMore => '查看更多';

  @override
  String get viewLess => '收起';

  @override
  String get courseContent => '课程内容';

  @override
  String videosCount(int count) {
    return '$count个视频';
  }

  @override
  String get selected => '已选择';

  @override
  String get selectThisCourse => '选择此课程';
}
