import 'package:circle_wallet_platform_interface/src/method_channel_circle_wallet.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// {@template circle_wallet_platform}
/// The interface that implementations of circle_wallet must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `CircleWallet`.
///
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
/// this interface will be broken by newly added [CircleWalletPlatform] methods.
/// {@endtemplate}
abstract class CircleWalletPlatform extends PlatformInterface {
  /// {@macro circle_wallet_platform}
  CircleWalletPlatform() : super(token: _token);

  static final Object _token = Object();

  static CircleWalletPlatform _instance = MethodChannelCircleWallet();

  /// The default instance of [CircleWalletPlatform] to use.
  ///
  /// Defaults to [MethodChannelCircleWallet].
  static CircleWalletPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [CircleWalletPlatform] when they register themselves.
  static set instance(CircleWalletPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();
}
