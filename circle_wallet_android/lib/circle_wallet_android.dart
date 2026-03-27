import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [CircleWalletPlatform].
class CircleWalletAndroid extends CircleWalletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circle_wallet_android');

  /// Creates the Android implementation, registering the native call handler.
  CircleWalletAndroid() {
    // Listen for native → Flutter calls initiated by the native plugin.
    methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  /// Registers this class as the default instance of [CircleWalletPlatform]
  static void registerWith() {
    CircleWalletPlatform.instance = CircleWalletAndroid();
  }

  /// Callback invoked when the user taps "Forgot PIN?" inside the SDK UI.
  ///
  /// Your app should:
  ///  1. Call your backend's `POST /user/pin/restore` to obtain a restore
  ///     challenge ID.
  ///  2. Call [execute] again with that new challenge ID.
  VoidCallback? onForgotPin;

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onForgotPin':
        onForgotPin?.call();
      default:
        throw MissingPluginException('${call.method} not implemented');
    }
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<Map<dynamic, dynamic>> execute({
    required String appId,
    required String userToken,
    required String encryptionKey,
    required String challengeId,
    bool enableBiometricsPin = true,
  }) async {
    try {
      final args = <String, dynamic>{
        'appId': appId,
        'userToken': userToken,
        'encryptionKey': encryptionKey,
        'challengeId': challengeId,
        'enableBiometricsPin': enableBiometricsPin,
      };

      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'execute',
        args,
      );

      return result ?? <dynamic, dynamic>{};
    } on PlatformException catch (e) {
      throw Exception(
        'CircleWalletAndroid execute failed: ${e.code} → ${e.message}',
      );
    }
  }
}
