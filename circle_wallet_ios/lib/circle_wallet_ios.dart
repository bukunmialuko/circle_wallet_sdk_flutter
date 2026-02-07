import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The iOS implementation of [CircleWalletPlatform].
class CircleWalletIOS extends CircleWalletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circle_wallet_ios');

  /// Registers this class as the default instance of [CircleWalletPlatform]
  static void registerWith() {
    CircleWalletPlatform.instance = CircleWalletIOS();
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
  }) async {
    try {
      final args = <String, dynamic>{
        'appId': appId,
        'userToken': userToken,
        'encryptionKey': encryptionKey,
        'challengeId': challengeId,
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
