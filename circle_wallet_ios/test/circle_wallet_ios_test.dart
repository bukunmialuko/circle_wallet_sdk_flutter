import 'package:circle_wallet_ios/circle_wallet_ios.dart';
import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CircleWalletIOS', () {
    const kPlatformName = 'iOS';
    late CircleWalletIOS circleWallet;
    late List<MethodCall> log;

    setUp(() async {
      circleWallet = CircleWalletIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(circleWallet.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      CircleWalletIOS.registerWith();
      expect(CircleWalletPlatform.instance, isA<CircleWalletIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await circleWallet.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
