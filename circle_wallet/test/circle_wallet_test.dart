import 'package:circle_wallet/circle_wallet.dart';
import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCircleWalletPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CircleWalletPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(CircleWalletPlatform, () {
    late CircleWalletPlatform circleWalletPlatform;

    setUp(() {
      circleWalletPlatform = MockCircleWalletPlatform();
      CircleWalletPlatform.instance = circleWalletPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => circleWalletPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => circleWalletPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
