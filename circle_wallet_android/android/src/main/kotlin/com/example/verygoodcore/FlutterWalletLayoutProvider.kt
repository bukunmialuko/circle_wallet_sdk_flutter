package com.example.verygoodcore

import android.content.Context
import circle.programmablewallet.sdk.api.ApiError.ErrorCode
import circle.programmablewallet.sdk.presentation.IconTextConfig
import circle.programmablewallet.sdk.presentation.LayoutProvider
import circle.programmablewallet.sdk.presentation.LocalImageSetter
import circle.programmablewallet.sdk.presentation.Resource
import circle.programmablewallet.sdk.presentation.TextConfig

/**
 * Security confirmation copy and icons aligned with iOS WalletSdkAdapter.securityConfirmItems().
 *
 * B1 items display a numbered circle (circle: #9E9FA0, number: #6172F3) alongside each tip.
 */
class FlutterWalletLayoutProvider(private val context: Context) : LayoutProvider() {

    override fun getIconTextConfigs(key: Resource.IconTextsKey): Array<IconTextConfig?>? {
        if (key == Resource.IconTextsKey.securityConfirmationItems) {
            return arrayOf(
                makeItem(1, "This is the only way to recover my account access."),
                makeItem(2, "Owego won\u2019t store my answers so it\u2019s my responsibility to remember them."),
                makeItem(3, "I will lose access to my wallet and my digital assets if I forget my answers.")
            )
        }
        return super.getIconTextConfigs(key)
    }

    /** Creates a single [IconTextConfig] with a numbered circle icon and the given text. */
    private fun makeItem(number: Int, text: String): IconTextConfig {
        val resId = when (number) {
            1 -> R.drawable.pw_security_confirm_num_1
            2 -> R.drawable.pw_security_confirm_num_2
            3 -> R.drawable.pw_security_confirm_num_3
            else -> R.drawable.pw_security_confirm_num_1
        }
        return IconTextConfig(
            LocalImageSetter(resId),
            TextConfig(text)
        )
    }

    override fun getErrorString(code: ErrorCode): String? {
        return super.getErrorString(code)
    }
}
