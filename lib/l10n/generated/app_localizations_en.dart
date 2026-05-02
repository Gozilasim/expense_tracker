import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Expense';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose app display language.';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystemMode => 'System mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get systemDefault => 'Follow system';

  @override
  String get systemDefaultSubtitle => 'Use your device language when supported.';

  @override
  String get chineseLanguage => '华文';

  @override
  String get malayLanguage => 'Bahasa Melayu';

  @override
  String get englishLanguage => 'English';

  @override
  String get linkBackend => 'Link Backend';

  @override
  String get linkBackendSubtitle => 'Connect the OCR receipt scanning API.';

  @override
  String get categories => 'Categories';

  @override
  String get categoriesSubtitle => 'Create, edit, and delete expense categories.';

  @override
  String get data => 'Data';

  @override
  String get dataSubtitle => 'Backup or restore your local expense database.';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'Owner, GitHub profile, and DuitNow QR.';

  @override
  String get deleteExpenseTitle => 'Delete Expense?';

  @override
  String get deleteExpenseMessage => 'Are you sure you want to delete this expense?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get custom => 'Custom';

  @override
  String totalAmount(Object amount) {
    return 'Total: \$$amount';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get all => 'All';

  @override
  String get noExpensesFound => 'No expenses found.';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get scanning => 'Scanning...';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose From Gallery';

  @override
  String get loadingOcrApiUrl => 'Loading saved OCR API URL. Try again in a moment.';

  @override
  String get setOcrApiUrlFirst => 'Set your OCR Backend API URL first.';

  @override
  String get setOcrApiUrlBanner => 'Set OCR API URL before scanning receipts.';

  @override
  String get set => 'Set';

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get newExpense => 'New Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get noCategoriesSeed => 'No categories found. Restart app to seed.';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get categoriesSection => 'CATEGORIES';

  @override
  String get noCategoriesAvailable => 'No categories available.';

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteCategoryMessage(Object name) {
    return 'Delete \"$name\"? Related expenses might be affected.';
  }

  @override
  String get editCategory => 'Edit Category';

  @override
  String get newCategory => 'New Category';

  @override
  String get name => 'Name';

  @override
  String get pickColor => 'Pick a Color:';

  @override
  String get pickIcon => 'Pick an Icon:';

  @override
  String get colorAlreadyTaken => 'Color already taken! Please pick another.';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get thisMonth => 'This Month';

  @override
  String get receiptOcrBackend => 'Receipt OCR Backend';

  @override
  String get backendDescription => 'Connect the backend endpoint used when scanning receipts.';

  @override
  String get ocrBackendApiUrl => 'OCR Backend API URL';

  @override
  String get backendUrlHelp => 'Save the full backend API URL used for OCR receipt imports.';

  @override
  String get invalidApiUrl => 'Enter a valid full http/https API URL.';

  @override
  String get apiUrlCleared => 'OCR Backend API URL cleared.';

  @override
  String get apiUrlSaved => 'OCR Backend API URL saved.';

  @override
  String failedToSaveApiUrl(Object error) {
    return 'Failed to save API URL: $error';
  }

  @override
  String failedToLoadApiUrl(Object error) {
    return 'Failed to load saved API URL: $error';
  }

  @override
  String get saveApiUrl => 'Save API URL';

  @override
  String get saving => 'Saving...';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testing => 'Testing...';

  @override
  String get backupRestore => 'Backup and Restore';

  @override
  String get backupRestoreDescription => 'Export your local database or restore from a previous backup.';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataSubtitle => 'Export db.sqlite and share it as a backup file.';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataSubtitle => 'Import a backup file and replace local expense data.';

  @override
  String get noDatabaseBackup => 'No database found to backup!';

  @override
  String get backupShareText => 'My Expense backup (db.sqlite)';

  @override
  String get backupReady => 'Backup ready to share.';

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreBackupTitle => 'Restore Backup?';

  @override
  String get restoreBackupMessage => 'This will overwrite all current expense data with the selected backup. This action cannot be undone.\n\nDo you want to continue?';

  @override
  String get restore => 'Restore';

  @override
  String get restoreSuccess => 'Restored successfully! Restarting app is recommended.';

  @override
  String restoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get owner => 'Owner';

  @override
  String get ownerCoffeeMessage => 'If you feel satisfied, please treat the developer a coffee.';

  @override
  String get unableToOpenGithub => 'Unable to open GitHub link.';

  @override
  String get close => 'Close';

  @override
  String get tapToEnlarge => 'Tap to enlarge';

  @override
  String get reviewOcrEntries => 'Review OCR Entries';

  @override
  String get reviewOcrDescription => 'Review the extracted entries before saving them to your records.';

  @override
  String get selectAtLeastOneEntry => 'Select at least one entry to import.';

  @override
  String entryLabel(Object number) {
    return 'Entry $number';
  }

  @override
  String entryValidAmount(Object entry) {
    return '$entry must have a valid amount.';
  }

  @override
  String entryNewCategoryName(Object entry) {
    return '$entry must have a new category name.';
  }

  @override
  String entryCategorySelected(Object entry) {
    return '$entry must have a category selected.';
  }

  @override
  String get saveSelectedEntries => 'Save Selected Entries';

  @override
  String get date => 'Date';

  @override
  String get createNew => 'Create new...';

  @override
  String get newCategoryName => 'New Category Name';

  @override
  String get note => 'Note';

  @override
  String get serverPathNotFound => 'Server reached, but this OCR API path was not found.';

  @override
  String serverReturnedStatus(Object statusCode) {
    return 'Server reached, but it returned $statusCode.';
  }

  @override
  String get ocrServerReachable => 'OCR server is reachable.';

  @override
  String get connectionTimedOut => 'Connection timed out. Check the API URL and network.';

  @override
  String connectionTestFailed(Object error) {
    return 'Connection test failed: $error';
  }

  @override
  String get ocrRequestTimedOut => 'OCR request timed out. Check that the backend is running and reachable from this phone.';

  @override
  String get cannotResolveOcrHost => 'Cannot resolve the OCR API host. Check the URL domain or IP address.';

  @override
  String get ocrConnectionRefused => 'OCR backend refused the connection. Check that the server is running on this port.';

  @override
  String get ocrBackendUnreachable => 'OCR backend is unreachable. Check that the phone and server are on the same network.';

  @override
  String get cannotConnectOcrBackend => 'Cannot connect to the OCR backend. Check the API URL, Wi-Fi, and server firewall.';

  @override
  String get httpTrafficBlocked => 'HTTP traffic was blocked. Use HTTPS or allow cleartext traffic for local testing.';

  @override
  String get cannotConnectOcrNetwork => 'Cannot connect to the OCR backend. Check the API URL and network.';

  @override
  String get ocrScanFailed => 'OCR scan failed. Please try again.';

  @override
  String get recognitionServiceUnavailable => 'Recognition service is temporarily unavailable. Please try again later.';

  @override
  String get ocrRequestInvalid => 'OCR request is invalid. Please try again later.';

  @override
  String get recognitionFailed => 'Recognition failed. Please try again later.';

  @override
  String get uploadClearReceipt => 'Please upload a clear receipt photo.';

  @override
  String get receiptItemsUnreadable => 'The receipt line items are not readable. Please take a clearer photo.';

  @override
  String get categoryDataInvalid => 'Category data is invalid. Please try again later.';

  @override
  String get unsupportedImageType => 'Only JPEG, PNG, and WebP images are supported.';

  @override
  String get emptyImageFile => 'The selected image file is empty. Please choose another image.';

  @override
  String get imageTooLarge => 'Image must be 3 MB or smaller.';

  @override
  String get cameraPermissionBlocked => 'Camera permission is blocked. Open app settings to allow receipt scanning.';

  @override
  String get cameraPermissionRequired => 'Camera permission is required to take receipt photos.';

  @override
  String get photoPermissionBlocked => 'Photo permission is blocked. Open app settings to allow receipt imports.';

  @override
  String get photoPermissionRequired => 'Photo permission is required to choose receipt images.';
}
