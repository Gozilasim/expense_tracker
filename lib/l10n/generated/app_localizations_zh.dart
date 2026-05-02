import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '我的记账';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageSubtitle => '选择 App 显示语言。';

  @override
  String get theme => '主题';

  @override
  String get themeSystemMode => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get systemDefaultSubtitle => '系统语言受支持时自动使用。';

  @override
  String get chineseLanguage => '华文';

  @override
  String get malayLanguage => 'Bahasa Melayu';

  @override
  String get englishLanguage => 'English';

  @override
  String get linkBackend => '连接后端';

  @override
  String get linkBackendSubtitle => '连接 OCR 收据扫描 API。';

  @override
  String get categories => '分类';

  @override
  String get categoriesSubtitle => '创建、编辑和删除支出分类。';

  @override
  String get data => '数据';

  @override
  String get dataSubtitle => '备份或恢复本地支出数据库。';

  @override
  String get about => '关于';

  @override
  String get aboutSubtitle => '开发者、GitHub 资料和 DuitNow QR。';

  @override
  String get deleteExpenseTitle => '删除支出？';

  @override
  String get deleteExpenseMessage => '确定要删除这笔支出吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get custom => '自定义';

  @override
  String totalAmount(Object amount) {
    return '总计：$amount';
  }

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get all => '全部';

  @override
  String get noExpensesFound => '没有找到支出。';

  @override
  String get scanReceipt => '扫描收据';

  @override
  String get scanning => '扫描中...';

  @override
  String get addExpense => '添加支出';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get loadingOcrApiUrl => '正在载入已保存的 OCR API URL，请稍后再试。';

  @override
  String get setOcrApiUrlFirst => '请先设置 OCR 后端 API URL。';

  @override
  String get setOcrApiUrlBanner => '扫描收据前请先设置 OCR API URL。';

  @override
  String get set => '设置';

  @override
  String errorMessage(Object error) {
    return '错误：$error';
  }

  @override
  String get newExpense => '新增支出';

  @override
  String get editExpense => '编辑支出';

  @override
  String get pleaseSelectCategory => '请选择分类';

  @override
  String get amount => '金额';

  @override
  String get category => '分类';

  @override
  String get noCategoriesSeed => '没有找到分类。请重启 App 以建立默认分类。';

  @override
  String get noteOptional => '备注（可选）';

  @override
  String get updateExpense => '更新支出';

  @override
  String get saveExpense => '保存支出';

  @override
  String get categoriesSection => '分类';

  @override
  String get noCategoriesAvailable => '没有可用分类。';

  @override
  String get deleteCategoryTitle => '删除分类？';

  @override
  String deleteCategoryMessage(Object name) {
    return '删除“$name”？相关支出可能会受影响。';
  }

  @override
  String get editCategory => '编辑分类';

  @override
  String get newCategory => '新增分类';

  @override
  String get name => '名称';

  @override
  String get pickColor => '选择颜色：';

  @override
  String get pickIcon => '选择图标：';

  @override
  String get colorAlreadyTaken => '这个颜色已被使用，请选择其他颜色。';

  @override
  String get save => '保存';

  @override
  String get add => '添加';

  @override
  String get noDataForPeriod => '这个期间没有数据';

  @override
  String get dailyAverage => '每日平均';

  @override
  String get totalSpending => '总支出';

  @override
  String get thisMonth => '本月';

  @override
  String get receiptOcrBackend => '收据 OCR 后端';

  @override
  String get backendDescription => '连接扫描收据时使用的后端端点。';

  @override
  String get ocrBackendApiUrl => 'OCR 后端 API URL';

  @override
  String get backendUrlHelp => '保存用于 OCR 收据导入的完整后端 API URL。';

  @override
  String get invalidApiUrl => '请输入完整有效的 http/https API URL。';

  @override
  String get apiUrlCleared => '已清除 OCR 后端 API URL。';

  @override
  String get apiUrlSaved => '已保存 OCR 后端 API URL。';

  @override
  String failedToSaveApiUrl(Object error) {
    return '保存 API URL 失败：$error';
  }

  @override
  String failedToLoadApiUrl(Object error) {
    return '载入已保存 API URL 失败：$error';
  }

  @override
  String get saveApiUrl => '保存 API URL';

  @override
  String get saving => '保存中...';

  @override
  String get testConnection => '测试连接';

  @override
  String get testing => '测试中...';

  @override
  String get backupRestore => '备份与恢复';

  @override
  String get backupRestoreDescription => '导出本地数据库，或从之前的备份恢复。';

  @override
  String get backupData => '备份数据';

  @override
  String get backupDataSubtitle => '导出 db.sqlite 并分享为备份文件。';

  @override
  String get restoreData => '恢复数据';

  @override
  String get restoreDataSubtitle => '导入备份文件并替换本地支出数据。';

  @override
  String get noDatabaseBackup => '没有可备份的数据库！';

  @override
  String get backupShareText => '我的记账备份（db.sqlite）';

  @override
  String get backupReady => '备份已准备好分享。';

  @override
  String backupFailed(Object error) {
    return '备份失败：$error';
  }

  @override
  String get restoreBackupTitle => '恢复备份？';

  @override
  String get restoreBackupMessage => '这会用所选备份覆盖当前所有支出数据。此操作无法撤销。\n\n要继续吗？';

  @override
  String get restore => '恢复';

  @override
  String get restoreSuccess => '恢复成功！建议重启 App。';

  @override
  String restoreFailed(Object error) {
    return '恢复失败：$error';
  }

  @override
  String get owner => '开发者';

  @override
  String get ownerCoffeeMessage => '如果你觉得满意，可以请开发者喝一杯咖啡。';

  @override
  String get unableToOpenGithub => '无法打开 GitHub 链接。';

  @override
  String get close => '关闭';

  @override
  String get tapToEnlarge => '点按放大';

  @override
  String get reviewOcrEntries => '检查 OCR 条目';

  @override
  String get reviewOcrDescription => '保存到记录前，请先检查识别出的条目。';

  @override
  String get selectAtLeastOneEntry => '请至少选择一个条目导入。';

  @override
  String entryLabel(Object number) {
    return '条目 $number';
  }

  @override
  String entryValidAmount(Object entry) {
    return '$entry 必须有有效金额。';
  }

  @override
  String entryNewCategoryName(Object entry) {
    return '$entry 必须有新分类名称。';
  }

  @override
  String entryCategorySelected(Object entry) {
    return '$entry 必须选择分类。';
  }

  @override
  String get saveSelectedEntries => '保存所选条目';

  @override
  String get date => '日期';

  @override
  String get createNew => '创建新分类...';

  @override
  String get newCategoryName => '新分类名称';

  @override
  String get note => '备注';

  @override
  String get serverPathNotFound => '已连接服务器，但找不到这个 OCR API 路径。';

  @override
  String serverReturnedStatus(Object statusCode) {
    return '已连接服务器，但返回了 $statusCode。';
  }

  @override
  String get ocrServerReachable => 'OCR 服务器可连接。';

  @override
  String get connectionTimedOut => '连接超时。请检查 API URL 和网络。';

  @override
  String connectionTestFailed(Object error) {
    return '连接测试失败：$error';
  }

  @override
  String get ocrRequestTimedOut => 'OCR 请求超时。请确认后端正在运行，并且这部手机可以连接。';

  @override
  String get cannotResolveOcrHost => '无法解析 OCR API 主机。请检查 URL 域名或 IP 地址。';

  @override
  String get ocrConnectionRefused => 'OCR 后端拒绝连接。请确认服务器正在这个端口运行。';

  @override
  String get ocrBackendUnreachable => '无法连接 OCR 后端。请确认手机和服务器在同一个网络。';

  @override
  String get cannotConnectOcrBackend => '无法连接 OCR 后端。请检查 API URL、Wi-Fi 和服务器防火墙。';

  @override
  String get httpTrafficBlocked => 'HTTP 流量被阻止。请使用 HTTPS，或允许本地测试使用明文流量。';

  @override
  String get cannotConnectOcrNetwork => '无法连接 OCR 后端。请检查 API URL 和网络。';

  @override
  String get ocrScanFailed => 'OCR 扫描失败，请重试。';

  @override
  String get recognitionServiceUnavailable => '识别服务暂时不可用，请稍后再试。';

  @override
  String get ocrRequestInvalid => 'OCR 请求无效，请稍后再试。';

  @override
  String get recognitionFailed => '识别失败，请稍后再试。';

  @override
  String get uploadClearReceipt => '请上传清晰的收据照片。';

  @override
  String get receiptItemsUnreadable => '收据项目无法读取，请拍摄更清晰的照片。';

  @override
  String get categoryDataInvalid => '分类数据无效，请稍后再试。';

  @override
  String get unsupportedImageType => '只支持 JPEG、PNG 和 WebP 图片。';

  @override
  String get emptyImageFile => '所选图片文件为空，请选择其他图片。';

  @override
  String get imageTooLarge => '图片必须小于或等于 3 MB。';

  @override
  String get cameraPermissionBlocked => '相机权限已被阻止。请打开 App 设置以允许扫描收据。';

  @override
  String get cameraPermissionRequired => '需要相机权限才能拍摄收据照片。';

  @override
  String get photoPermissionBlocked => '照片权限已被阻止。请打开 App 设置以允许导入收据。';

  @override
  String get photoPermissionRequired => '需要照片权限才能选择收据图片。';
}
