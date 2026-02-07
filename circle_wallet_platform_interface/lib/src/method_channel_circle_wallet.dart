import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// An implementation of [CircleWalletPlatform] that uses method channels.
class MethodChannelCircleWallet extends CircleWalletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circle_wallet');

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

      if (result == null) return <String, dynamic>{};

      return result.map((key, value) => MapEntry(key.toString(), value));
    } on PlatformException catch (e) {
      throw Exception('CircleWallet execute failed: ${e.code}: ${e.message}');
    }
  }
}
