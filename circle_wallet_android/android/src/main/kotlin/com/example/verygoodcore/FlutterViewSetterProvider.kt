package com.example.verygoodcore

import circle.programmablewallet.sdk.presentation.IImageViewSetter
import circle.programmablewallet.sdk.presentation.IToolbarSetter
import circle.programmablewallet.sdk.presentation.LocalImageSetter
import circle.programmablewallet.sdk.presentation.LocalToolbarImageSetter
import circle.programmablewallet.sdk.presentation.Resource
import circle.programmablewallet.sdk.presentation.ViewSetterProvider

/**
 * Custom ViewSetterProvider that supplies local drawables for the icons used
 * by the Circle Wallet SDK so they are visible on the dark #0D0F11 background.
 *
 * Icon → D-code mapping (per Circle docs):
 * - D1:  securityIntroMain    → Owego logo (intro screen hero image)
 * - D5:  securityConfirmMain  → Owego logo (confirm screen hero image)
 * - D6:  showPin              → white eye icon
 * - D7:  hidePin              → white eye-slash icon
 * - D8:  dropdownArrow        → white chevron
 * - D10: back (ToolbarIcon)   → white back arrow
 * - D11: close (ToolbarIcon)  → white back arrow (reused until close asset available)
 */
class FlutterViewSetterProvider : ViewSetterProvider() {

    /** In-page icons: hero images (D1, D5), PIN toggle (D6, D7), dropdown (D8). */
    override fun getImageSetter(type: Resource.Icon): IImageViewSetter? {
        val drawableId = when (type) {
            Resource.Icon.securityIntroMain    -> R.drawable.pw_owego_logo
            Resource.Icon.securityConfirmMain  -> R.drawable.pw_owego_logo
            Resource.Icon.showPin              -> R.drawable.pw_icon_show_pin
            Resource.Icon.hidePin              -> R.drawable.pw_icon_hide_pin
            Resource.Icon.dropdownArrow        -> R.drawable.pw_icon_dropdown_arrow
            else                               -> return super.getImageSetter(type)
        }
        return LocalImageSetter(drawableId)
    }

    override fun getToolbarImageSetter(type: Resource.ToolbarIcon): IToolbarSetter? {
        val drawableId = when (type) {
            Resource.ToolbarIcon.back  -> R.drawable.pw_icon_back_scaled
            Resource.ToolbarIcon.close -> R.drawable.pw_icon_close_scaled
        }
        return LocalToolbarImageSetter(drawableId)
    }
}
