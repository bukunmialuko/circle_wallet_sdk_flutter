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
 * - showPin / hidePin / dropdownArrow → [Resource.Icon] (in-page icons)
 * - back                              → [Resource.ToolbarIcon] (toolbar icon)
 */
class FlutterViewSetterProvider : ViewSetterProvider() {

    /** In-page icons: show/hide PIN toggle, dropdown chevron. */
    override fun getImageSetter(type: Resource.Icon): IImageViewSetter? {
        val drawableId = when (type) {
            Resource.Icon.showPin       -> R.drawable.pw_icon_show_pin
            Resource.Icon.hidePin       -> R.drawable.pw_icon_hide_pin
            Resource.Icon.dropdownArrow -> R.drawable.pw_icon_dropdown_arrow
            else                        -> return super.getImageSetter(type)
        }
        return LocalImageSetter(drawableId)
    }

    /** Toolbar icons: back arrow and close button. */
    override fun getToolbarImageSetter(type: Resource.ToolbarIcon): IToolbarSetter? {
        val drawableId = when (type) {
            Resource.ToolbarIcon.back  -> R.drawable.pw_icon_back
            Resource.ToolbarIcon.close -> R.drawable.pw_icon_back
        }
        return LocalToolbarImageSetter(drawableId)
    }
}
