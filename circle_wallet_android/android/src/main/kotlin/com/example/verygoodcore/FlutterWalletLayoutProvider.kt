package com.example.verygoodcore

import circle.programmablewallet.sdk.api.ApiError.ErrorCode
import circle.programmablewallet.sdk.presentation.IconTextConfig
import circle.programmablewallet.sdk.presentation.LayoutProvider
import circle.programmablewallet.sdk.presentation.RemoteImageSetter
import circle.programmablewallet.sdk.presentation.Resource
import circle.programmablewallet.sdk.presentation.TextConfig

/**
 * Security confirmation copy aligned with iOS `WalletSdkAdapter.securityConfirmItems()`.
 *
 * Global PW SDK chrome (backgrounds, typography, buttons) is themed via Android resource merge:
 * override `circlepw_*` colors and `circlepw_dark_status_bar` in the host app under
 * `android/app/src/main/res/values/` (see example `circle_pw_theme_colors.xml`).
 */
class FlutterWalletLayoutProvider : LayoutProvider() {

    private val remotePlaceholderUrls = arrayOf(
        "https://circle.com/w3s/security-intro/0",
        "https://circle.com/w3s/security-intro/1",
        "https://circle.com/w3s/security-intro/2"
    )

    override fun getIconTextConfigs(key: Resource.IconTextsKey): Array<IconTextConfig?>? {
        if (key == Resource.IconTextsKey.securityConfirmationItems) {
            return arrayOf<IconTextConfig?>(
                IconTextConfig(
                    RemoteImageSetter(
                        R.drawable.pw_security_intro_1,
                        remotePlaceholderUrls[0]
                    ),
                    TextConfig(
                        "This is the only way to recover my account access."
                    )
                ),
                IconTextConfig(
                    RemoteImageSetter(
                        R.drawable.pw_security_intro_2,
                        remotePlaceholderUrls[1]
                    ),
                    TextConfig(
                        "Owego won\u2019t store my answers so it\u2019s my responsibility to remember them."
                    )
                ),
                IconTextConfig(
                    RemoteImageSetter(
                        R.drawable.pw_security_intro_3,
                        remotePlaceholderUrls[2]
                    ),
                    TextConfig(
                        "I will lose access to my wallet and my digital assets if I forget my answers."
                    )
                )
            )
        }
        return super.getIconTextConfigs(key)
    }

    override fun getErrorString(code: ErrorCode): String? {
        return super.getErrorString(code)
    }
}
