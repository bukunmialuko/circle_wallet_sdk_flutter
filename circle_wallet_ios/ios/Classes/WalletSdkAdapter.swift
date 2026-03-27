import Foundation
import UIKit
import CircleProgrammableWalletSDK

final class WalletSdkAdapter: NSObject {

    private var didSetProviders = false
    private var lastConfigKey: String?

    func ensureConfigured(endPoint: String, appId: String) throws {
        let trimmedAppId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = "\(endPoint)|\(trimmedAppId)"

        if !didSetProviders {
            WalletSdk.shared.setLayoutProvider(self)
            WalletSdk.shared.setErrorMessenger(self)
            WalletSdk.shared.setDelegate(self)
            didSetProviders = true
        }

        if lastConfigKey != key {
            let settings = WalletSdk.SettingsManagement(
                enableBiometricsPin: false,
                pinCodeInputType: .numericPad
            )
            let configuration = WalletSdk.Configuration(
                endPoint: endPoint,
                appId: trimmedAppId,
                settingsManagement: settings
            )
            try WalletSdk.shared.setConfiguration(configuration)
            lastConfigKey = key
        }
    }
}

extension WalletSdkAdapter: WalletSdkLayoutProvider {

    func securityQuestions() -> [SecurityQuestion] {
        return [
            SecurityQuestion(title: "What is your father’s middle name?", inputType: .text),
            SecurityQuestion(title: "What is your favorite sports team?", inputType: .text),
            SecurityQuestion(title: "What is your mother’s maiden name?", inputType: .text),
            SecurityQuestion(title: "What is the name of your first pet?", inputType: .text),
            SecurityQuestion(title: "What is the name of the city you were born in?", inputType: .text),
            SecurityQuestion(title: "What is the name of the first street you lived on?", inputType: .text),
            SecurityQuestion(title: "When is your father’s birthday?", inputType: .datePicker)
        ]
    }

    func securityQuestionsRequiredCount() -> Int { 2 }

    func securityConfirmItems() -> [SecurityConfirmItem] { [
        SecurityConfirmItem(image: UIImage(named: "img_item_1"),
            text: "This is the only way to recover my account access."),
        SecurityConfirmItem(image: UIImage(named: "img_item_2"),
            text: "Owego won’t store my answers so it’s my responsibility to remember them."),
        SecurityConfirmItem(image: UIImage(named: "img_item_3"),
            text: "I will lose access to my wallet and my digital assets if I forget my answers."),
        ]
    }

    func themeFont() -> ThemeConfig.ThemeFont? {
        // "Open Runde" is not bundled in iOS by default; Nunito Sans is the
        // closest available system-style match. Swap the font name below once
        // the font is embedded in the host app bundle.
        guard let font = UIFont(name: "NunitoSans-Regular", size: 16) else {
            return nil
        }
        return ThemeConfig.ThemeFont(
            urlString: nil,
            bigTitleFont: UIFont(name: "NunitoSans-Bold", size: 28) ?? font,
            titleFont: UIFont(name: "NunitoSans-Bold", size: 20) ?? font,
            subtitleFont: UIFont(name: "NunitoSans-SemiBold", size: 16) ?? font,
            bodyFont: font,
            labelFont: UIFont(name: "NunitoSans-Regular", size: 14) ?? font
        )
    }

    // Brand colour palette mirroring the Android resource overrides
    private enum BrandColor {
        static let background   = UIColor(hex: "#0D0F11")
        static let surface      = UIColor(hex: "#161A1E")
        static let accent       = UIColor(hex: "#6172F3")
        static let primaryText  = UIColor.white
        static let secondaryText = UIColor(hex: "#9E9FA0")
        static let buttonBg     = UIColor(hex: "#FCFCFD")
        static let buttonText   = UIColor.black
        static let inputFill    = UIColor(hex: "#1C2126")
        static let border       = UIColor(hex: "#252A30")
    }

    func imageStore() -> ImageStore {
        ImageStore(local: [:], remote: [:])
    }

    func displayDateFormat() -> String { "yyyy/MM/dd" }
}

extension WalletSdkAdapter: ErrorMessenger {
    func getErrorString(_ code: ApiError.ErrorCode) -> String? { nil }
}

extension WalletSdkAdapter: WalletSdkDelegate {

    func walletSdk(willPresentController controller: UIViewController) {
        // SDK handles its own UI
    }

    func walletSdk(controller: UIViewController, onForgetPINButtonSelected onSelect: Void) {
        controller.dismiss(animated: true)
    }

    func walletSdk(controller: UIViewController, onSendAgainButtonSelected onSelect: Void) {
        controller.dismiss(animated: true)
    }
}
