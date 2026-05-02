import 'app_localizations.dart';

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Perbelanjaan Saya';

  @override
  String get settings => 'Tetapan';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSubtitle => 'Pilih bahasa paparan aplikasi.';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystemMode => 'Ikut sistem';

  @override
  String get themeLight => 'Cerah';

  @override
  String get themeDark => 'Gelap';

  @override
  String get systemDefault => 'Ikut sistem';

  @override
  String get systemDefaultSubtitle => 'Guna bahasa peranti jika disokong.';

  @override
  String get chineseLanguage => '华文';

  @override
  String get malayLanguage => 'Bahasa Melayu';

  @override
  String get englishLanguage => 'English';

  @override
  String get linkBackend => 'Pautkan Backend';

  @override
  String get linkBackendSubtitle => 'Sambungkan API imbasan resit OCR.';

  @override
  String get categories => 'Kategori';

  @override
  String get categoriesSubtitle => 'Cipta, edit dan padam kategori perbelanjaan.';

  @override
  String get data => 'Data';

  @override
  String get dataSubtitle => 'Sandar atau pulihkan pangkalan data tempatan.';

  @override
  String get about => 'Tentang';

  @override
  String get aboutSubtitle => 'Pemilik, profil GitHub dan DuitNow QR.';

  @override
  String get deleteExpenseTitle => 'Padam Perbelanjaan?';

  @override
  String get deleteExpenseMessage => 'Anda pasti mahu memadam perbelanjaan ini?';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Padam';

  @override
  String get retry => 'Cuba Lagi';

  @override
  String get month => 'Bulan';

  @override
  String get year => 'Tahun';

  @override
  String get custom => 'Tersuai';

  @override
  String totalAmount(Object amount) {
    return 'Jumlah: $amount';
  }

  @override
  String get today => 'Hari Ini';

  @override
  String get yesterday => 'Semalam';

  @override
  String get all => 'Semua';

  @override
  String get noExpensesFound => 'Tiada perbelanjaan ditemui.';

  @override
  String get scanReceipt => 'Imbas Resit';

  @override
  String get scanning => 'Mengimbas...';

  @override
  String get addExpense => 'Tambah Belanja';

  @override
  String get takePhoto => 'Ambil Foto';

  @override
  String get chooseFromGallery => 'Pilih Dari Galeri';

  @override
  String get loadingOcrApiUrl => 'Memuatkan OCR API URL yang disimpan. Cuba lagi sebentar nanti.';

  @override
  String get setOcrApiUrlFirst => 'Tetapkan OCR Backend API URL dahulu.';

  @override
  String get setOcrApiUrlBanner => 'Tetapkan OCR API URL sebelum mengimbas resit.';

  @override
  String get set => 'Tetapkan';

  @override
  String errorMessage(Object error) {
    return 'Ralat: $error';
  }

  @override
  String get newExpense => 'Perbelanjaan Baharu';

  @override
  String get editExpense => 'Edit Perbelanjaan';

  @override
  String get pleaseSelectCategory => 'Sila pilih kategori';

  @override
  String get amount => 'Amaun';

  @override
  String get category => 'Kategori';

  @override
  String get noCategoriesSeed => 'Tiada kategori ditemui. Mulakan semula aplikasi untuk mencipta kategori lalai.';

  @override
  String get noteOptional => 'Nota (Pilihan)';

  @override
  String get updateExpense => 'Kemas Kini Perbelanjaan';

  @override
  String get saveExpense => 'Simpan Perbelanjaan';

  @override
  String get categoriesSection => 'KATEGORI';

  @override
  String get noCategoriesAvailable => 'Tiada kategori tersedia.';

  @override
  String get deleteCategoryTitle => 'Padam Kategori?';

  @override
  String deleteCategoryMessage(Object name) {
    return 'Padam \"$name\"? Perbelanjaan berkaitan mungkin terjejas.';
  }

  @override
  String get editCategory => 'Edit Kategori';

  @override
  String get newCategory => 'Kategori Baharu';

  @override
  String get name => 'Nama';

  @override
  String get pickColor => 'Pilih Warna:';

  @override
  String get pickIcon => 'Pilih Ikon:';

  @override
  String get colorAlreadyTaken => 'Warna sudah digunakan! Sila pilih warna lain.';

  @override
  String get save => 'Simpan';

  @override
  String get add => 'Tambah';

  @override
  String get noDataForPeriod => 'Tiada data untuk tempoh ini';

  @override
  String get dailyAverage => 'Purata Harian';

  @override
  String get totalSpending => 'Jumlah Belanja';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get receiptOcrBackend => 'Backend OCR Resit';

  @override
  String get backendDescription => 'Sambungkan endpoint backend yang digunakan semasa mengimbas resit.';

  @override
  String get ocrBackendApiUrl => 'OCR Backend API URL';

  @override
  String get backendUrlHelp => 'Simpan URL API backend penuh untuk import resit OCR.';

  @override
  String get invalidApiUrl => 'Masukkan URL API http/https yang lengkap dan sah.';

  @override
  String get apiUrlCleared => 'OCR Backend API URL telah dikosongkan.';

  @override
  String get apiUrlSaved => 'OCR Backend API URL telah disimpan.';

  @override
  String failedToSaveApiUrl(Object error) {
    return 'Gagal menyimpan API URL: $error';
  }

  @override
  String failedToLoadApiUrl(Object error) {
    return 'Gagal memuatkan API URL tersimpan: $error';
  }

  @override
  String get saveApiUrl => 'Simpan API URL';

  @override
  String get saving => 'Menyimpan...';

  @override
  String get testConnection => 'Uji Sambungan';

  @override
  String get testing => 'Menguji...';

  @override
  String get backupRestore => 'Sandaran dan Pemulihan';

  @override
  String get backupRestoreDescription => 'Eksport pangkalan data tempatan atau pulihkan daripada sandaran lama.';

  @override
  String get backupData => 'Sandar Data';

  @override
  String get backupDataSubtitle => 'Eksport db.sqlite dan kongsi sebagai fail sandaran.';

  @override
  String get restoreData => 'Pulihkan Data';

  @override
  String get restoreDataSubtitle => 'Import fail sandaran dan gantikan data perbelanjaan tempatan.';

  @override
  String get noDatabaseBackup => 'Tiada pangkalan data untuk disandar!';

  @override
  String get backupShareText => 'Sandaran Perbelanjaan Saya (db.sqlite)';

  @override
  String get backupReady => 'Sandaran sedia untuk dikongsi.';

  @override
  String backupFailed(Object error) {
    return 'Sandaran gagal: $error';
  }

  @override
  String get restoreBackupTitle => 'Pulihkan Sandaran?';

  @override
  String get restoreBackupMessage => 'Ini akan menimpa semua data perbelanjaan semasa dengan sandaran yang dipilih. Tindakan ini tidak boleh dibuat asal.\n\nTeruskan?';

  @override
  String get restore => 'Pulihkan';

  @override
  String get restoreSuccess => 'Berjaya dipulihkan! Anda disarankan memulakan semula aplikasi.';

  @override
  String restoreFailed(Object error) {
    return 'Pemulihan gagal: $error';
  }

  @override
  String get owner => 'Pemilik';

  @override
  String get ownerCoffeeMessage => 'Jika anda berpuas hati, belanja pembangun secawan kopi.';

  @override
  String get unableToOpenGithub => 'Tidak dapat membuka pautan GitHub.';

  @override
  String get close => 'Tutup';

  @override
  String get tapToEnlarge => 'Ketik untuk besarkan';

  @override
  String get reviewOcrEntries => 'Semak Entri OCR';

  @override
  String get reviewOcrDescription => 'Semak entri yang diekstrak sebelum menyimpannya ke rekod anda.';

  @override
  String get selectAtLeastOneEntry => 'Pilih sekurang-kurangnya satu entri untuk diimport.';

  @override
  String entryLabel(Object number) {
    return 'Entri $number';
  }

  @override
  String entryValidAmount(Object entry) {
    return '$entry mesti mempunyai amaun yang sah.';
  }

  @override
  String entryNewCategoryName(Object entry) {
    return '$entry mesti mempunyai nama kategori baharu.';
  }

  @override
  String entryCategorySelected(Object entry) {
    return '$entry mesti memilih kategori.';
  }

  @override
  String get saveSelectedEntries => 'Simpan Entri Dipilih';

  @override
  String get date => 'Tarikh';

  @override
  String get createNew => 'Cipta baharu...';

  @override
  String get newCategoryName => 'Nama Kategori Baharu';

  @override
  String get note => 'Nota';

  @override
  String get serverPathNotFound => 'Server dicapai, tetapi laluan API OCR ini tidak ditemui.';

  @override
  String serverReturnedStatus(Object statusCode) {
    return 'Server dicapai, tetapi mengembalikan $statusCode.';
  }

  @override
  String get ocrServerReachable => 'Server OCR boleh dicapai.';

  @override
  String get connectionTimedOut => 'Sambungan tamat masa. Semak API URL dan rangkaian.';

  @override
  String connectionTestFailed(Object error) {
    return 'Ujian sambungan gagal: $error';
  }

  @override
  String get ocrRequestTimedOut => 'Permintaan OCR tamat masa. Pastikan backend berjalan dan boleh dicapai dari telefon ini.';

  @override
  String get cannotResolveOcrHost => 'Tidak dapat mengenal pasti hos OCR API. Semak domain URL atau alamat IP.';

  @override
  String get ocrConnectionRefused => 'Backend OCR menolak sambungan. Pastikan server berjalan pada port ini.';

  @override
  String get ocrBackendUnreachable => 'Backend OCR tidak dapat dicapai. Pastikan telefon dan server berada pada rangkaian yang sama.';

  @override
  String get cannotConnectOcrBackend => 'Tidak dapat menyambung ke backend OCR. Semak API URL, Wi-Fi dan firewall server.';

  @override
  String get httpTrafficBlocked => 'Trafik HTTP disekat. Gunakan HTTPS atau benarkan trafik jelas untuk ujian tempatan.';

  @override
  String get cannotConnectOcrNetwork => 'Tidak dapat menyambung ke backend OCR. Semak API URL dan rangkaian.';

  @override
  String get ocrScanFailed => 'Imbasan OCR gagal. Sila cuba lagi.';

  @override
  String get recognitionServiceUnavailable => 'Perkhidmatan pengecaman tidak tersedia buat sementara. Cuba lagi kemudian.';

  @override
  String get ocrRequestInvalid => 'Permintaan OCR tidak sah. Cuba lagi kemudian.';

  @override
  String get recognitionFailed => 'Pengecaman gagal. Cuba lagi kemudian.';

  @override
  String get uploadClearReceipt => 'Sila muat naik foto resit yang jelas.';

  @override
  String get receiptItemsUnreadable => 'Butiran resit tidak dapat dibaca. Sila ambil foto yang lebih jelas.';

  @override
  String get categoryDataInvalid => 'Data kategori tidak sah. Cuba lagi kemudian.';

  @override
  String get unsupportedImageType => 'Hanya imej JPEG, PNG dan WebP disokong.';

  @override
  String get emptyImageFile => 'Fail imej yang dipilih kosong. Sila pilih imej lain.';

  @override
  String get imageTooLarge => 'Imej mesti 3 MB atau lebih kecil.';

  @override
  String get cameraPermissionBlocked => 'Kebenaran kamera disekat. Buka tetapan aplikasi untuk membenarkan imbasan resit.';

  @override
  String get cameraPermissionRequired => 'Kebenaran kamera diperlukan untuk mengambil foto resit.';

  @override
  String get photoPermissionBlocked => 'Kebenaran foto disekat. Buka tetapan aplikasi untuk membenarkan import resit.';

  @override
  String get photoPermissionRequired => 'Kebenaran foto diperlukan untuk memilih imej resit.';
}
