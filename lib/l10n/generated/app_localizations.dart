import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Expense'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app display language.'**
  String get languageSubtitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystemMode.
  ///
  /// In en, this message translates to:
  /// **'System mode'**
  String get themeSystemMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get systemDefault;

  /// No description provided for @systemDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your device language when supported.'**
  String get systemDefaultSubtitle;

  /// No description provided for @chineseLanguage.
  ///
  /// In en, this message translates to:
  /// **'华文'**
  String get chineseLanguage;

  /// No description provided for @malayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get malayLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @linkBackend.
  ///
  /// In en, this message translates to:
  /// **'Link Backend'**
  String get linkBackend;

  /// No description provided for @linkBackendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect the OCR receipt scanning API.'**
  String get linkBackendSubtitle;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, and delete expense categories.'**
  String get categoriesSubtitle;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @dataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup or restore your local expense database.'**
  String get dataSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owner, GitHub profile, and DuitNow QR.'**
  String get aboutSubtitle;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: \${amount}'**
  String totalAmount(Object amount);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found.'**
  String get noExpensesFound;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose From Gallery'**
  String get chooseFromGallery;

  /// No description provided for @loadingOcrApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Loading saved OCR API URL. Try again in a moment.'**
  String get loadingOcrApiUrl;

  /// No description provided for @setOcrApiUrlFirst.
  ///
  /// In en, this message translates to:
  /// **'Set your OCR Backend API URL first.'**
  String get setOcrApiUrlFirst;

  /// No description provided for @setOcrApiUrlBanner.
  ///
  /// In en, this message translates to:
  /// **'Set OCR API URL before scanning receipts.'**
  String get setOcrApiUrlBanner;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(Object error);

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noCategoriesSeed.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Restart app to seed.'**
  String get noCategoriesSeed;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptional;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @categoriesSection.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categoriesSection;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available.'**
  String get noCategoriesAvailable;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Related expenses might be affected.'**
  String deleteCategoryMessage(Object name);

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a Color:'**
  String get pickColor;

  /// No description provided for @pickIcon.
  ///
  /// In en, this message translates to:
  /// **'Pick an Icon:'**
  String get pickIcon;

  /// No description provided for @colorAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'Color already taken! Please pick another.'**
  String get colorAlreadyTaken;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get totalSpending;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @receiptOcrBackend.
  ///
  /// In en, this message translates to:
  /// **'Receipt OCR Backend'**
  String get receiptOcrBackend;

  /// No description provided for @backendDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect the backend endpoint used when scanning receipts.'**
  String get backendDescription;

  /// No description provided for @ocrBackendApiUrl.
  ///
  /// In en, this message translates to:
  /// **'OCR Backend API URL'**
  String get ocrBackendApiUrl;

  /// No description provided for @backendUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Save the full backend API URL used for OCR receipt imports.'**
  String get backendUrlHelp;

  /// No description provided for @invalidApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid full http/https API URL.'**
  String get invalidApiUrl;

  /// No description provided for @apiUrlCleared.
  ///
  /// In en, this message translates to:
  /// **'OCR Backend API URL cleared.'**
  String get apiUrlCleared;

  /// No description provided for @apiUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'OCR Backend API URL saved.'**
  String get apiUrlSaved;

  /// No description provided for @failedToSaveApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Failed to save API URL: {error}'**
  String failedToSaveApiUrl(Object error);

  /// No description provided for @failedToLoadApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved API URL: {error}'**
  String failedToLoadApiUrl(Object error);

  /// No description provided for @saveApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Save API URL'**
  String get saveApiUrl;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your local database or restore from a previous backup.'**
  String get backupRestoreDescription;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export db.sqlite and share it as a backup file.'**
  String get backupDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a backup file and replace local expense data.'**
  String get restoreDataSubtitle;

  /// No description provided for @noDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'No database found to backup!'**
  String get noDatabaseBackup;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'My Expense backup (db.sqlite)'**
  String get backupShareText;

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to share.'**
  String get backupReady;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite all current expense data with the selected backup. This action cannot be undone.\n\nDo you want to continue?'**
  String get restoreBackupMessage;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored successfully! Restarting app is recommended.'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @ownerCoffeeMessage.
  ///
  /// In en, this message translates to:
  /// **'If you feel satisfied, please treat the developer a coffee.'**
  String get ownerCoffeeMessage;

  /// No description provided for @unableToOpenGithub.
  ///
  /// In en, this message translates to:
  /// **'Unable to open GitHub link.'**
  String get unableToOpenGithub;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tapToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Tap to enlarge'**
  String get tapToEnlarge;

  /// No description provided for @reviewOcrEntries.
  ///
  /// In en, this message translates to:
  /// **'Review OCR Entries'**
  String get reviewOcrEntries;

  /// No description provided for @reviewOcrDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the extracted entries before saving them to your records.'**
  String get reviewOcrDescription;

  /// No description provided for @selectAtLeastOneEntry.
  ///
  /// In en, this message translates to:
  /// **'Select at least one entry to import.'**
  String get selectAtLeastOneEntry;

  /// No description provided for @entryLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry {number}'**
  String entryLabel(Object number);

  /// No description provided for @entryValidAmount.
  ///
  /// In en, this message translates to:
  /// **'{entry} must have a valid amount.'**
  String entryValidAmount(Object entry);

  /// No description provided for @entryNewCategoryName.
  ///
  /// In en, this message translates to:
  /// **'{entry} must have a new category name.'**
  String entryNewCategoryName(Object entry);

  /// No description provided for @entryCategorySelected.
  ///
  /// In en, this message translates to:
  /// **'{entry} must have a category selected.'**
  String entryCategorySelected(Object entry);

  /// No description provided for @saveSelectedEntries.
  ///
  /// In en, this message translates to:
  /// **'Save Selected Entries'**
  String get saveSelectedEntries;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new...'**
  String get createNew;

  /// No description provided for @newCategoryName.
  ///
  /// In en, this message translates to:
  /// **'New Category Name'**
  String get newCategoryName;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @serverPathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Server reached, but this OCR API path was not found.'**
  String get serverPathNotFound;

  /// No description provided for @serverReturnedStatus.
  ///
  /// In en, this message translates to:
  /// **'Server reached, but it returned {statusCode}.'**
  String serverReturnedStatus(Object statusCode);

  /// No description provided for @ocrServerReachable.
  ///
  /// In en, this message translates to:
  /// **'OCR server is reachable.'**
  String get ocrServerReachable;

  /// No description provided for @connectionTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check the API URL and network.'**
  String get connectionTimedOut;

  /// No description provided for @connectionTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed: {error}'**
  String connectionTestFailed(Object error);

  /// No description provided for @ocrRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'OCR request timed out. Check that the backend is running and reachable from this phone.'**
  String get ocrRequestTimedOut;

  /// No description provided for @cannotResolveOcrHost.
  ///
  /// In en, this message translates to:
  /// **'Cannot resolve the OCR API host. Check the URL domain or IP address.'**
  String get cannotResolveOcrHost;

  /// No description provided for @ocrConnectionRefused.
  ///
  /// In en, this message translates to:
  /// **'OCR backend refused the connection. Check that the server is running on this port.'**
  String get ocrConnectionRefused;

  /// No description provided for @ocrBackendUnreachable.
  ///
  /// In en, this message translates to:
  /// **'OCR backend is unreachable. Check that the phone and server are on the same network.'**
  String get ocrBackendUnreachable;

  /// No description provided for @cannotConnectOcrBackend.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the OCR backend. Check the API URL, Wi-Fi, and server firewall.'**
  String get cannotConnectOcrBackend;

  /// No description provided for @httpTrafficBlocked.
  ///
  /// In en, this message translates to:
  /// **'HTTP traffic was blocked. Use HTTPS or allow cleartext traffic for local testing.'**
  String get httpTrafficBlocked;

  /// No description provided for @cannotConnectOcrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the OCR backend. Check the API URL and network.'**
  String get cannotConnectOcrNetwork;

  /// No description provided for @ocrScanFailed.
  ///
  /// In en, this message translates to:
  /// **'OCR scan failed. Please try again.'**
  String get ocrScanFailed;

  /// No description provided for @recognitionServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Recognition service is temporarily unavailable. Please try again later.'**
  String get recognitionServiceUnavailable;

  /// No description provided for @ocrRequestInvalid.
  ///
  /// In en, this message translates to:
  /// **'OCR request is invalid. Please try again later.'**
  String get ocrRequestInvalid;

  /// No description provided for @recognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'Recognition failed. Please try again later.'**
  String get recognitionFailed;

  /// No description provided for @uploadClearReceipt.
  ///
  /// In en, this message translates to:
  /// **'Please upload a clear receipt photo.'**
  String get uploadClearReceipt;

  /// No description provided for @receiptItemsUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The receipt line items are not readable. Please take a clearer photo.'**
  String get receiptItemsUnreadable;

  /// No description provided for @categoryDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'Category data is invalid. Please try again later.'**
  String get categoryDataInvalid;

  /// No description provided for @unsupportedImageType.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG, PNG, and WebP images are supported.'**
  String get unsupportedImageType;

  /// No description provided for @emptyImageFile.
  ///
  /// In en, this message translates to:
  /// **'The selected image file is empty. Please choose another image.'**
  String get emptyImageFile;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image must be 3 MB or smaller.'**
  String get imageTooLarge;

  /// No description provided for @cameraPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is blocked. Open app settings to allow receipt scanning.'**
  String get cameraPermissionBlocked;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take receipt photos.'**
  String get cameraPermissionRequired;

  /// No description provided for @photoPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Photo permission is blocked. Open app settings to allow receipt imports.'**
  String get photoPermissionBlocked;

  /// No description provided for @photoPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo permission is required to choose receipt images.'**
  String get photoPermissionRequired;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ms': return AppLocalizationsMs();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
