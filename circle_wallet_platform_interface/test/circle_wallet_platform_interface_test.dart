import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class CircleWalletMock extends CircleWalletPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

  @override
  Future<Map<dynamic, dynamic>> execute({
    required String appId,
    required String userToken,
    required String encryptionKey,
    required String challengeId,
  }) {
    // TODO: implement execute
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CircleWalletPlatformInterface', () {
    late CircleWalletPlatform circleWalletPlatform;

    setUp(() {
      circleWalletPlatform = CircleWalletMock();
      CircleWalletPlatform.instance = circleWalletPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await CircleWalletPlatform.instance.getPlatformName(),
          equals(CircleWalletMock.mockPlatformName),
        );
      });
    });
  });
}
