import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../../core/errors/failures.dart';

enum MediaPermissionType { camera, microphone, both }

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  final Logger _logger = Logger();

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      _logger.e('Error checking camera permission: $e');
      return false;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      _logger.e('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Check if both camera and microphone permissions are granted
  Future<bool> areMediaPermissionsGranted() async {
    final cameraGranted = await isCameraPermissionGranted();
    final microphoneGranted = await isMicrophonePermissionGranted();
    return cameraGranted && microphoneGranted;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _logger.i('Camera permission status: $status');
      return status;
    } catch (e) {
      _logger.e('Error requesting camera permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      _logger.i('Microphone permission status: $status');
      return status;
    } catch (e) {
      _logger.e('Error requesting microphone permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request both camera and microphone permissions
  Future<Map<Permission, PermissionStatus>> requestMediaPermissions() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      
      _logger.i('Media permissions status: $statuses');
      return statuses;
    } catch (e) {
      _logger.e('Error requesting media permissions: $e');
      return {
        Permission.camera: PermissionStatus.denied,
        Permission.microphone: PermissionStatus.denied,
      };
    }
  }

  /// Request specific media permission type
  Future<bool> requestPermission(MediaPermissionType type) async {
    switch (type) {
      case MediaPermissionType.camera:
        final status = await requestCameraPermission();
        return status.isGranted;
      case MediaPermissionType.microphone:
        final status = await requestMicrophonePermission();
        return status.isGranted;
      case MediaPermissionType.both:
        final statuses = await requestMediaPermissions();
        return statuses.values.every((status) => status.isGranted);
    }
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      _logger.e('Error checking if permission is permanently denied: $e');
      return false;
    }
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      _logger.e('Error opening app settings: $e');
      return false;
    }
  }

  /// Get permission status message for UI
  String getPermissionStatusMessage(PermissionStatus status, String permissionName) {
    switch (status) {
      case PermissionStatus.granted:
        return '$permissionName permission granted';
      case PermissionStatus.denied:
        return '$permissionName permission denied. Please grant permission to continue.';
      case PermissionStatus.restricted:
        return '$permissionName permission is restricted on this device';
      case PermissionStatus.limited:
        return '$permissionName permission is limited';
      case PermissionStatus.permanentlyDenied:
        return '$permissionName permission permanently denied. Please enable it in app settings.';
      case PermissionStatus.provisional:
        return '$permissionName permission is provisional';
    }
  }

  /// Handle permission denial with appropriate action
  Future<void> handlePermissionDenial(
    Permission permission,
    String permissionName,
    Function() onSettingsOpen,
  ) async {
    final isPermanentlyDenied = await isPermissionPermanentlyDenied(permission);
    
    if (isPermanentlyDenied) {
      // Show dialog to open settings
      final opened = await openAppSettings();
      if (opened) {
        onSettingsOpen();
      }
    } else {
      // Show explanation and request again
      _logger.w('$permissionName permission denied, but can be requested again');
    }
  }

  /// Validate media permissions before starting a meeting
  Future<MediaPermissionValidationResult> validateMediaPermissions({
    bool requireCamera = true,
    bool requireMicrophone = true,
  }) async {
    final results = <String>[];
    bool allGranted = true;

    if (requireCamera) {
      final cameraGranted = await isCameraPermissionGranted();
      if (!cameraGranted) {
        results.add('Camera permission is required for video calls');
        allGranted = false;
      }
    }

    if (requireMicrophone) {
      final microphoneGranted = await isMicrophonePermissionGranted();
      if (!microphoneGranted) {
        results.add('Microphone permission is required for audio calls');
        allGranted = false;
      }
    }

    return MediaPermissionValidationResult(
      isValid: allGranted,
      errors: results,
    );
  }
}

class MediaPermissionValidationResult {
  final bool isValid;
  final List<String> errors;

  MediaPermissionValidationResult({
    required this.isValid,
    required this.errors,
  });
}
