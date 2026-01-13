import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'closeVibration': 'Close Vibration',
      'closeVibrationDesc': 'Turn off haptic feedback',
      'reverseSwipe': 'Reverse Swipe',
      'reverseSwipeDesc': 'Swap up/down actions',
      'topBarCollapsible': 'Collapsible Top Bar',
      'topBarCollapsibleDesc': 'Hide top bar on scroll',
      'languageAuto': 'Auto',
      'loadFailed': 'Load Failed',
      'aboutTitle': 'About MemCull',
      'thanks': 'Acknowledgements',
      'currentVersion': 'Current Version',
      'checkNewVersion': 'View New Releases',
      'faq': 'FAQ',
      'privacyPolicy': 'Privacy Policy & Terms',
      'developerName': 'Developer',
      'donateDeveloper': 'Donate',
      'donateDescFree': 'MemCull is free. ',
      'donateDescFreeHighlight': 'Forever. ',
      'donateDescLbs': 'If you like it, ',
      'donateDescLbsHighlight': 'buy me a coffee. ',
      'donateDescHelp': 'It helps! ',
      'donateDescHelpHighlight': '',
      'donateDescThanks': 'Thank you ',
      'donateDescThanksHighlight': 'very much!',
      'undo': 'Undo',
      'recycleBin': 'Trash',
      'keep': 'Keep',
      'welcomeTitle': 'Welcome',
      'welcomeSubtitle': 'Organize your photos easily',
      'swipeUpDelete': 'Swipe Up to Delete',
      'swipeDownKeep': 'Swipe Down to Keep',
      'startButton': 'Skip',
      'emptyRecycleBin': 'Empty Trash',
      'emptyConfirmContent':
          'Are you sure you want to permanently delete all items in the trash? This action cannot be undone.',
      'emptyLabel': 'Empty',
      'cancel': 'Cancel',
      'selectAll': 'Select All',
      'recycleBinEmpty': 'Trash is empty',
      'recover': 'Recover',
      'delete': 'Delete',
      'languageZhCn': 'Simplified Chinese',
      'language': 'Language',
      'languageZhHk': 'Traditional Chinese (HK)',
      'languageZhTw': 'Traditional Chinese (TW)',
      'languageEn': 'English',
      'permanentlyDeleteTitle': 'Permanently Delete',
      'info': 'Info',
      'cameraParamsLabel': 'Camera',
      'storageLocation': 'Path',
      'unknown': 'Unknown',
      'locationDisplay': 'Location Display',
      'locationDisplayDesc':
          'Based on the EXIF metadata embedded in the image, the specific location of the image cannot be displayed directly. Since this is a free version, MemCull no longer provides relevant reverse geocoding services. If you have a need for specific image location display, please follow the guide to configure the reverse geocoding service provided by Amap. The free quota is sufficient for individual users. (Currently only mainland China is supported, and support for other map platform APIs will be introduced later)',
      'goToConfig': 'Go to Config',
      'amapKeyHint': 'Enter Amap Web Service Key',
      'amapConfigGuide': 'Amap Key Configuration Guide',
      'photoInfo': 'Photo Info',
      'createTime': 'Date Taken',
      'captureLocation': 'Location',
      'noLocationInfo': 'No location info',
      'fileInfo': 'File Info',
      'networkError': 'Network Error',
      'quotaExhausted': 'LBS Quota Exhausted',
      'readingCameraParams': 'Reading...',
      'noCameraParams': 'No camera info',
      'permissionDesc':
          'MemCull needs access to your photos to help you organize them.',
      'grantPermission': 'Grant Permission',
      'openSettings': 'Open Settings',
      'roundCompletedTitle': 'All Done!',
      'roundCompletedSubtitle': 'You have organized all your photos.',
      'allPhotosProcessed': 'No more photos to organize.',
      'fetchingLocation': 'Fetching location...',
      'locationError': 'Location Error',
      'amapStep1Title': 'Register and Log in to Amap Open Platform',
      'amapStep1Desc':
          'Visit https://lbs.amap.com/ and complete account registration.',
      'amapStep2Title':
          'Go to Console -> Application Management -> My Applications',
      'amapStep2Desc':
          'Click "Create New Application", fill in the application name and type (suggest selecting "Other").',
      'amapStep3Title': 'Add a New Key for the Application',
      'amapStep3Desc':
          'Click "Add Key", make sure to select "Web Service" for the Service Platform.',
      'amapStep4Title': 'Copy the Key and Paste Above',
      'amapStep4Desc':
          'After successful creation, copy the generated Key string and paste it into the input box on this page.',
      'configSaved': 'Configuration Saved',
      'amapServiceNotice':
          'Note: Please make sure to select the "Web Service" type Key, otherwise reverse geocoding will not work properly.',
      'goNow': 'Go Now >',
    },
    'zh': {
      'settings': '设置',
      'closeVibration': '关闭震动',
      'closeVibrationDesc': '关闭触感反馈',
      'reverseSwipe': '反转滑动',
      'reverseSwipeDesc': '交换上下滑动作',
      'topBarCollapsible': '顶部栏可折叠',
      'topBarCollapsibleDesc': '滚动时隐藏顶部栏',
      'languageAuto': '跟随系统',
      'loadFailed': '加载失败',
      'aboutTitle': '关于 MemCull',
      'thanks': '致谢',
      'currentVersion': '当前版本',
      'checkNewVersion': '查看新版发布',
      'faq': '常见问题',
      'privacyPolicy': '隐私政策与服务条款',
      'developerName': '开发者',
      'donateDeveloper': '捐赠',
      'donateDescFree': 'MemCull 是免费的。',
      'donateDescFreeHighlight': '永远。',
      'donateDescLbs': '如果你喜欢，',
      'donateDescLbsHighlight': '请我喝杯咖啡。',
      'donateDescHelp': '这很有帮助！',
      'donateDescHelpHighlight': '',
      'donateDescThanks': '非常',
      'donateDescThanksHighlight': '感谢！',
      'undo': '撤销',
      'recycleBin': '回收站',
      'keep': '保留',
      'welcomeTitle': '欢迎',
      'welcomeSubtitle': '轻松整理您的照片',
      'swipeUpDelete': '上滑删除',
      'swipeDownKeep': '下滑保留',
      'startButton': '跳过',
      'emptyRecycleBin': '清空回收站',
      'emptyConfirmContent': '确定要永久删除回收站中的所有项目吗？此操作无法撤销。',
      'emptyLabel': '清空',
      'cancel': '取消',
      'selectAll': '全选',
      'recycleBinEmpty': '回收站为空',
      'recover': '恢复',
      'delete': '删除',
      'languageZhCn': '简体中文',
      'language': '语言',
      'languageZhHk': '繁体中文 (香港)',
      'languageZhTw': '繁体中文 (台湾)',
      'languageEn': 'English',
      'permanentlyDeleteTitle': '永久删除',
      'info': '信息',
      'cameraParamsLabel': '相机',
      'storageLocation': '路径',
      'unknown': '未知',
      'locationDisplay': '具体位置显示',
      'locationDisplayDesc':
          '基于图片内嵌的 EXIF 元数据无法直接显示图片具体位置，由于这是免费提供的版本，MemCull 不再提供相关逆地理编码功能，如果您有图片具体位置显示的需求，请按引导配置由高德提供的逆地理编码服务。免费额度对个人用户来说是足够的。（当前仅支持中国大陆，后期将引入其他平台地图 API 支持）',
      'goToConfig': '前往配置',
      'amapKeyHint': '输入高德 Web 服务 Key',
      'amapConfigGuide': '高德 Key 配置指南',
      'photoInfo': '照片信息',
      'createTime': '拍摄时间',
      'captureLocation': '拍摄地点',
      'noLocationInfo': '无位置信息',
      'fileInfo': '文件信息',
      'networkError': '网络错误',
      'quotaExhausted': 'LBS 配额耗尽',
      'readingCameraParams': '读取中...',
      'noCameraParams': '无相机信息',
      'permissionDesc': 'MemCull 需要访问您的照片以帮助您整理它们。',
      'grantPermission': '授予权限',
      'openSettings': '打开设置',
      'roundCompletedTitle': '全部完成！',
      'roundCompletedSubtitle': '您已整理完所有照片。',
      'allPhotosProcessed': '没有更多照片需要整理。',
      'fetchingLocation': '获取位置中...',
      'locationError': '定位错误',
      'amapStep1Title': '注册并登录高德开放平台',
      'amapStep1Desc': '访问 https://lbs.amap.com/ 并完成账号注册。',
      'amapStep2Title': '进入控制台 -> 应用管理 -> 我的应用',
      'amapStep2Desc': '点击“创建新应用”，填写应用名称和类型（建议选“其他”）。',
      'amapStep3Title': '为应用添加新 Key',
      'amapStep3Desc': '点击“添加Key”，服务平台务必选择“Web 服务”。',
      'amapStep4Title': '复制 Key 并粘贴到上方',
      'amapStep4Desc': '成功创建后，复制生成的 Key 字符串粘贴到此页面的输入框中。',
      'configSaved': '配置已保存',
      'amapServiceNotice': '注意：请确保选择的是“Web 服务”类型的 Key，否则逆地理编码将无法正常工作。',
      'goNow': '立即前往 >',
    },
    'zh_HK': {
      'settings': '設置',
      'closeVibration': '關閉震動',
      'closeVibrationDesc': '關閉觸感回饋',
      'reverseSwipe': '反轉滑動',
      'reverseSwipeDesc': '交換上下滑動作',
      'topBarCollapsible': '頂部欄可折疊',
      'topBarCollapsibleDesc': '滾動時隱藏頂部欄',
      'languageAuto': '跟隨系統',
      'loadFailed': '載入失敗',
      'aboutTitle': '關於 MemCull',
      'thanks': '致謝',
      'currentVersion': '目前版本',
      'checkNewVersion': '查看新版發佈',
      'faq': '常見問題',
      'privacyPolicy': '隱私政策與服務條款',
      'developerName': '開發者',
      'donateDeveloper': '捐贈',
      'donateDescFree': 'MemCull 是免費的。',
      'donateDescFreeHighlight': '永遠。',
      'donateDescLbs': '如果你喜歡，',
      'donateDescLbsHighlight': '請我喝杯咖啡。',
      'donateDescHelp': '這很有幫助！',
      'donateDescHelpHighlight': '',
      'donateDescThanks': '非常',
      'donateDescThanksHighlight': '感謝！',
      'undo': '撤銷',
      'recycleBin': '回收箱',
      'keep': '保留',
      'welcomeTitle': '歡迎',
      'welcomeSubtitle': '輕鬆整理您的照片',
      'swipeUpDelete': '上滑刪除',
      'swipeDownKeep': '下滑保留',
      'startButton': '跳過',
      'emptyRecycleBin': '清空回收箱',
      'emptyConfirmContent': '確定要永久刪除回收箱中的所有項目嗎？此操作無法撤銷。',
      'emptyLabel': '清空',
      'cancel': '取消',
      'selectAll': '全選',
      'recycleBinEmpty': '回收箱為空',
      'recover': '恢復',
      'delete': '刪除',
      'languageZhCn': '簡體中文',
      'language': '語言',
      'languageZhHk': '繁體中文 (香港)',
      'languageZhTw': '繁體中文 (台灣)',
      'languageEn': 'English',
      'permanentlyDeleteTitle': '永久刪除',
      'info': '資訊',
      'cameraParamsLabel': '相機',
      'storageLocation': '路徑',
      'unknown': '未知',
      'locationDisplay': '具體位置顯示',
      'locationDisplayDesc':
          '基於圖片內嵌的 EXIF 中繼資料無法直接顯示圖片具體位置，由於這是免費提供的版本，MemCull 不再提供相關逆地理編碼功能，如果您有圖片具體位置顯示的需求，請按引導配置由高德提供的逆地理編碼服務。免費額度對個人用戶來說是足夠的。（目前僅支援中國大陸，後期將引入其他平台地圖 API 支援）',
      'goToConfig': '前往配置',
      'amapKeyHint': '輸入高德 Web 服務 Key',
      'amapConfigGuide': '高德 Key 配置指南',
      'photoInfo': '照片資訊',
      'createTime': '拍攝時間',
      'captureLocation': '拍攝地點',
      'noLocationInfo': '無位置資訊',
      'fileInfo': '檔案資訊',
      'networkError': '網路錯誤',
      'quotaExhausted': 'LBS 配額耗盡',
      'readingCameraParams': '讀取中...',
      'noCameraParams': '無相機資訊',
      'permissionDesc': 'MemCull 需要存取您的照片以幫助您整理它們。',
      'grantPermission': '授予權限',
      'openSettings': '打開設置',
      'roundCompletedTitle': '全部完成！',
      'roundCompletedSubtitle': '您已整理完所有照片。',
      'allPhotosProcessed': '沒有更多照片需要整理。',
      'fetchingLocation': '獲取位置中...',
      'locationError': '定位錯誤',
      'amapStep1Title': '註冊並登錄高德開放平台',
      'amapStep1Desc': '訪問 https://lbs.amap.com/ 並完成帳號註冊。',
      'amapStep2Title': '進入控制台 -> 應用管理 -> 我的應用',
      'amapStep2Desc': '點擊「創建新應用」，填寫應用名稱和類型（建議選「其他」）。',
      'amapStep3Title': '為應用添加新 Key',
      'amapStep3Desc': '點擊「添加Key」，服務平台務必選擇「Web 服務」。',
      'amapStep4Title': '複製 Key 並貼上到上方',
      'amapStep4Desc': '成功創建後，複製生成的 Key 字串並貼上到此頁面的輸入框中。',
      'configSaved': '配置已儲存',
      'amapServiceNotice': '注意：請確保選擇的是「Web 服務」類型的 Key，否則逆地理編碼將無法正常工作。',
      'goNow': '立即前往 >',
    },
    'zh_TW': {
      'settings': '設置',
      'closeVibration': '關閉震動',
      'closeVibrationDesc': '關閉觸感回饋',
      'reverseSwipe': '反轉滑動',
      'reverseSwipeDesc': '交換上下滑動作',
      'topBarCollapsible': '頂部欄可折疊',
      'topBarCollapsibleDesc': '滾動時隱藏頂部欄',
      'languageAuto': '跟隨系統',
      'loadFailed': '載入失敗',
      'aboutTitle': '關於 MemCull',
      'thanks': '致謝',
      'currentVersion': '目前版本',
      'checkNewVersion': '查看新版發佈',
      'faq': '常見問題',
      'privacyPolicy': '隱私政策與服務條款',
      'developerName': '開發者',
      'donateDeveloper': '捐贈',
      'donateDescFree': 'MemCull 是免費的。',
      'donateDescFreeHighlight': '永遠。',
      'donateDescLbs': '如果你喜歡，',
      'donateDescLbsHighlight': '請我喝杯咖啡。',
      'donateDescHelp': '這很有幫助！',
      'donateDescHelpHighlight': '',
      'donateDescThanks': '非常',
      'donateDescThanksHighlight': '感謝！',
      'undo': '撤銷',
      'recycleBin': '回收箱',
      'keep': '保留',
      'welcomeTitle': '歡迎',
      'welcomeSubtitle': '輕鬆整理您的照片',
      'swipeUpDelete': '上滑刪除',
      'swipeDownKeep': '下滑保留',
      'startButton': '跳過',
      'emptyRecycleBin': '清空回收箱',
      'emptyConfirmContent': '確定要永久刪除回收箱中的所有項目嗎？此操作無法撤銷。',
      'emptyLabel': '清空',
      'cancel': '取消',
      'selectAll': '全選',
      'recycleBinEmpty': '回收箱為空',
      'recover': '恢復',
      'delete': '刪除',
      'languageZhCn': '簡體中文',
      'language': '語言',
      'languageZhHk': '繁體中文 (香港)',
      'languageZhTw': '繁體中文 (台灣)',
      'languageEn': 'English',
      'permanentlyDeleteTitle': '永久刪除',
      'info': '資訊',
      'cameraParamsLabel': '相機',
      'storageLocation': '路徑',
      'unknown': '未知',
      'locationDisplay': '具體位置顯示',
      'locationDisplayDesc':
          '基於圖片內嵌的 EXIF 中繼資料無法直接顯示圖片具體位置，由於這是免費提供的版本，MemCull 不再提供相關逆地理編碼功能，如果您有圖片具體位置顯示的需求，請按引導配置由高德提供的逆地理編碼服務。免費額度對個人用戶來說是足夠的。（目前僅支援中國大陸，後期將引入其他平台地圖 API 支援）',
      'goToConfig': '前往配置',
      'amapKeyHint': '輸入高德 Web 服務 Key',
      'amapConfigGuide': '高德 Key 配置指南',
      'photoInfo': '照片資訊',
      'createTime': '拍攝時間',
      'captureLocation': '拍攝地點',
      'noLocationInfo': '無位置資訊',
      'fileInfo': '檔案資訊',
      'networkError': '網路錯誤',
      'quotaExhausted': 'LBS 配額耗盡',
      'readingCameraParams': '讀取中...',
      'noCameraParams': '無相機資訊',
      'permissionDesc': 'MemCull 需要存取您的照片以幫助您整理它們。',
      'grantPermission': '授予權限',
      'openSettings': '打開設置',
      'roundCompletedTitle': '全部完成！',
      'roundCompletedSubtitle': '您已整理完所有照片。',
      'allPhotosProcessed': '沒有更多照片需要整理。',
      'fetchingLocation': '獲取位置中...',
      'locationError': '定位錯誤',
      'amapStep1Title': '註冊並登錄高德開放平台',
      'amapStep1Desc': '訪問 https://lbs.amap.com/ 並完成帳號註冊。',
      'amapStep2Title': '進入控制台 -> 應用管理 -> 我的應用',
      'amapStep2Desc': '點擊「創建新應用」，填寫應用名稱和類型（建議選「其他」）。',
      'amapStep3Title': '為應用添加新 Key',
      'amapStep3Desc': '點擊「添加Key」，服務平台務必選擇「Web 服務」。',
      'amapStep4Title': '複製 Key 並貼上到上方',
      'amapStep4Desc': '成功創建後，複製生成的 Key 字串並貼上到此頁面的輸入框中。',
      'configSaved': '配置已儲存',
      'amapServiceNotice': '注意：請確保選擇的是「Web 服務」類型的 Key，否則逆地理編碼將無法正常工作。',
      'goNow': '立即前往 >',
    },
  };

  String _get(String key) {
    final String localeStr = locale.toString();
    if (_localizedValues.containsKey(localeStr)) {
      return _localizedValues[localeStr]![key] ?? _localizedValues['en']![key]!;
    }
    return _localizedValues[locale.languageCode]![key] ??
        _localizedValues['en']![key]!;
  }

  String get settings => _get('settings');
  String get closeVibration => _get('closeVibration');
  String get closeVibrationDesc => _get('closeVibrationDesc');
  String get reverseSwipe => _get('reverseSwipe');
  String get reverseSwipeDesc => _get('reverseSwipeDesc');
  String get topBarCollapsible => _get('topBarCollapsible');
  String get topBarCollapsibleDesc => _get('topBarCollapsibleDesc');
  String get languageAuto => _get('languageAuto');
  String get loadFailed => _get('loadFailed');
  String get aboutTitle => _get('aboutTitle');
  String get thanks => _get('thanks');
  String get currentVersion => _get('currentVersion');
  String get checkNewVersion => _get('checkNewVersion');
  String get faq => _get('faq');
  String get privacyPolicy => _get('privacyPolicy');
  String get developerName => _get('developerName');
  String get donateDeveloper => _get('donateDeveloper');
  String get donateDescFree => _get('donateDescFree');
  String get donateDescFreeHighlight => _get('donateDescFreeHighlight');
  String get donateDescLbs => _get('donateDescLbs');
  String get donateDescLbsHighlight => _get('donateDescLbsHighlight');
  String get donateDescHelp => _get('donateDescHelp');
  String get donateDescHelpHighlight => _get('donateDescHelpHighlight');
  String get donateDescThanks => _get('donateDescThanks');
  String get donateDescThanksHighlight => _get('donateDescThanksHighlight');
  String get undo => _get('undo');
  String get recycleBin => _get('recycleBin');
  String get keep => _get('keep');
  String get welcomeTitle => _get('welcomeTitle');
  String get welcomeSubtitle => _get('welcomeSubtitle');
  String get swipeUpDelete => _get('swipeUpDelete');
  String get swipeDownKeep => _get('swipeDownKeep');
  String get startButton => _get('startButton');
  String get emptyRecycleBin => _get('emptyRecycleBin');
  String get emptyConfirmContent => _get('emptyConfirmContent');
  String get emptyLabel => _get('emptyLabel');
  String get cancel => _get('cancel');
  String get selectAll => _get('selectAll');
  String get recycleBinEmpty => _get('recycleBinEmpty');
  String get recover => _get('recover');
  String get delete => _get('delete');
  String get languageZhCn => _get('languageZhCn');
  String get language => _get('language');
  String get languageZhHk => _get('languageZhHk');
  String get languageZhTw => _get('languageZhTw');
  String get languageEn => _get('languageEn');
  String get permanentlyDeleteTitle => _get('permanentlyDeleteTitle');
  String get info => _get('info');
  String get cameraParamsLabel => _get('cameraParamsLabel');
  String get storageLocation => _get('storageLocation');
  String get unknown => _get('unknown');
  String get locationDisplay => _get('locationDisplay');
  String get locationDisplayDesc => _get('locationDisplayDesc');
  String get goToConfig => _get('goToConfig');
  String get amapKeyHint => _get('amapKeyHint');
  String get amapConfigGuide => _get('amapConfigGuide');
  String get photoInfo => _get('photoInfo');
  String get createTime => _get('createTime');
  String get captureLocation => _get('captureLocation');
  String get noLocationInfo => _get('noLocationInfo');
  String get fileInfo => _get('fileInfo');
  String get networkError => _get('networkError');
  String get quotaExhausted => _get('quotaExhausted');
  String get readingCameraParams => _get('readingCameraParams');
  String get noCameraParams => _get('noCameraParams');
  String get permissionDesc => _get('permissionDesc');
  String get grantPermission => _get('grantPermission');
  String get openSettings => _get('openSettings');
  String get roundCompletedTitle => _get('roundCompletedTitle');
  String get roundCompletedSubtitle => _get('roundCompletedSubtitle');
  String get allPhotosProcessed => _get('allPhotosProcessed');
  String get fetchingLocation => _get('fetchingLocation');
  String get locationError => _get('locationError');
  String get amapStep1Title => _get('amapStep1Title');
  String get amapStep1Desc => _get('amapStep1Desc');
  String get amapStep2Title => _get('amapStep2Title');
  String get amapStep2Desc => _get('amapStep2Desc');
  String get amapStep3Title => _get('amapStep3Title');
  String get amapStep3Desc => _get('amapStep3Desc');
  String get amapStep4Title => _get('amapStep4Title');
  String get amapStep4Desc => _get('amapStep4Desc');
  String get configSaved => _get('configSaved');
  String get amapServiceNotice => _get('amapServiceNotice');
  String get goNow => _get('goNow');

  String selectedCount(int count) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '已選擇 $count 項';
      }
      return '已选择 $count 项';
    }
    return 'Selected $count items';
  }

  String permanentlyDeleteContent(int count) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '確定要永久刪除這 $count 個項目嗎？此操作無法撤銷。';
      }
      return '确定要永久删除这 $count 个项目吗？此操作无法撤销。';
    }
    return 'Are you sure you want to permanently delete these $count items? This action cannot be undone.';
  }

  String dateLabel(String date) {
    if (locale.languageCode == 'zh') {
      return '日期: $date';
    }
    return 'Date: $date';
  }

  String resolutionLabel(int width, int height) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '解析度: ${width}x$height';
      }
      return '分辨率: ${width}x$height';
    }
    return 'Resolution: ${width}x$height';
  }

  String longitudeLabel(String longitude) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '經度: $longitude';
      }
      return '经度: $longitude';
    }
    return 'Longitude: $longitude';
  }

  String latitudeLabel(String latitude) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '緯度: $latitude';
      }
      return '纬度: $latitude';
    }
    return 'Latitude: $latitude';
  }

  String filenameLabel(String filename) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '檔案名稱: $filename';
      }
      return '文件名称: $filename';
    }
    return 'Filename: $filename';
  }

  String sizeLabel(String size) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '檔案大小: $size';
      }
      return '大小: $size';
    }
    return 'Size: $size';
  }

  String deviceLabel(String device) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '裝置: $device';
      }
      return '设备: $device';
    }
    return 'Device: $device';
  }

  String lensLabel(String lens) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '鏡頭: $lens';
      }
      return '镜头: $lens';
    }
    return 'Lens: $lens';
  }

  String paramsLabel(String params) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '參數: $params';
      }
      return '参数: $params';
    }
    return 'Params: $params';
  }

  String readFailed(String error) {
    if (locale.languageCode == 'zh') {
      if (locale.toString().contains('HK') ||
          locale.toString().contains('TW')) {
        return '讀取失敗: $error';
      }
      return '读取失败: $error';
    }
    return 'Read Failed: $error';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
