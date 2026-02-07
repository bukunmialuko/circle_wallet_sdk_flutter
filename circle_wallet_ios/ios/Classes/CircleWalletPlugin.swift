import Flutter
import UIKit

public class CircleWalletPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "circle_wallet_ios", binaryMessenger: registrar.messenger())
    let instance = CircleWalletPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS")
  }
}
