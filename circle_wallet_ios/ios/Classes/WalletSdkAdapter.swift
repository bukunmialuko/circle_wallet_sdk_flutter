import Foundation
import UIKit
import CircleProgrammableWalletSDK

final class WalletSdkAdapter: NSObject {

    private var didSetProviders = false
    private var lastConfigKey: String?

    func ensureConfigured(endPoint: String, appId: String, enableBiometricsPin: Bool) throws {
        let trimmedAppId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = "\(endPoint)|\(trimmedAppId)|\(enableBiometricsPin)"

        if !didSetProviders {
            WalletSdk.shared.setLayoutProvider(self)
            WalletSdk.shared.setErrorMessenger(self)
            WalletSdk.shared.setDelegate(self)
            didSetProviders = true
        }

        if lastConfigKey != key {
            let settings = WalletSdk.SettingsManagement(
                enableBiometricsPin: enableBiometricsPin
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
        return ThemeConfig.ThemeFont(
            regular: "OpenRunde-Regular",
            medium: "OpenRunde-Medium",
            semibold: "OpenRunde-Semibold",
            bold: "OpenRunde-Bold"
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
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
        }
    }

    func walletSdk(controller: UIViewController, onSendAgainButtonSelected onSelect: Void) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
        }
    }
}

extension UIColor {
    convenience init(hex: String, defaultColor: UIColor = .white) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }
        if hexSanitized.count == 6 {
            let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            self.init(cgColor: defaultColor.cgColor)
        }
    }
}
