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
            let settings = WalletSdk.SettingsManagement(enableBiometricsPin: false)
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

    func securityConfirmItems() -> [SecurityConfirmItem] { [] }

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
