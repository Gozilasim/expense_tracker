import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptImagePermissionResult {
  const ReceiptImagePermissionResult({
    required this.allowed,
    required this.message,
    required this.canOpenSettings,
  });

  final bool allowed;
  final String message;
  final bool canOpenSettings;
}

Future<ReceiptImagePermissionResult> requestReceiptImagePermission(
  ImageSource source,
) async {
  if (source == ImageSource.camera) {
    return _requestCameraPermission();
  }

  return _requestGalleryPermission();
}

Future<void> openReceiptPermissionSettings() => openAppSettings();

Future<ReceiptImagePermissionResult> _requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (_isAllowed(status)) {
    return const ReceiptImagePermissionResult(
      allowed: true,
      message: '',
      canOpenSettings: false,
    );
  }

  return ReceiptImagePermissionResult(
    allowed: false,
    message: status.isPermanentlyDenied
        ? 'Camera permission is blocked. Open app settings to allow receipt scanning.'
        : 'Camera permission is required to take receipt photos.',
    canOpenSettings: status.isPermanentlyDenied || status.isRestricted,
  );
}

Future<ReceiptImagePermissionResult> _requestGalleryPermission() async {
  final photosStatus = await Permission.photos.request();
  if (_isAllowed(photosStatus)) {
    return const ReceiptImagePermissionResult(
      allowed: true,
      message: '',
      canOpenSettings: false,
    );
  }

  final storageStatus = await Permission.storage.request();
  if (_isAllowed(storageStatus)) {
    return const ReceiptImagePermissionResult(
      allowed: true,
      message: '',
      canOpenSettings: false,
    );
  }

  final permanentlyDenied =
      photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;
  return ReceiptImagePermissionResult(
    allowed: false,
    message: permanentlyDenied
        ? 'Photo permission is blocked. Open app settings to allow receipt imports.'
        : 'Photo permission is required to choose receipt images.',
    canOpenSettings: permanentlyDenied ||
        photosStatus.isRestricted ||
        storageStatus.isRestricted,
  );
}

bool _isAllowed(PermissionStatus status) {
  return status.isGranted || status.isLimited;
}
