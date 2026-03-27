import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [CircleWalletPlatform].
class CircleWalletAndroid extends CircleWalletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circle_wallet_android');

  /// The event channel used to receive events from the native plugin.
  ///
  /// Currently emits a single event type: `forgotPin`.
  @visibleForTesting
  final eventChannel = const EventChannel('circle_wallet_android/events');

  /// Registers this class as the default instance of [CircleWalletPlatform].
  static void registerWith() {
    CircleWalletPlatform.instance = CircleWalletAndroid();
  }

  /// A stream that emits whenever the user taps "Forgot PIN?" inside the
  /// SDK UI. Listen to this to trigger the PIN-restore flow:
  ///   1. Call `POST /user/pin/restore` on your backend to get a restore
  ///      challenge ID.
  ///   2. Call [execute] again with that challenge ID.
  @override
  Stream<void> get forgotPinStream =>
      eventChannel.receiveBroadcastStream().where(
            (event) => event == 'forgotPin',
          );

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
