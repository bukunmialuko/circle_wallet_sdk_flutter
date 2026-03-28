import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [CircleWalletPlatform].
class CircleWalletAndroid extends CircleWalletPlatform {
  /// Creates the Android implementation, registering the native call handler.
  CircleWalletAndroid() {
    methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circle_wallet_android');

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
        return null;
      default:
        throw MissingPluginException('${call.method} not implemented');
    }
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<Map<String, dynamic>> execute({
    required String appId,
    required String userToken,
    required String encryptionKey,
    required String challengeId,
    bool enableBiometricsPin = false,
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

      if (result == null) return <String, dynamic>{};
      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException catch (e) {
      throw Exception(
        'CircleWalletAndroid execute failed: ${e.code} → ${e.message}',
      );
    }
  }
}
