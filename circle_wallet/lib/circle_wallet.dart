import 'package:circle_wallet_platform_interface/circle_wallet_platform_interface.dart';

CircleWalletPlatform get _platform => CircleWalletPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}
