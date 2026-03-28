package com.example.verygoodcore

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Activity
import android.content.Context
import circle.programmablewallet.sdk.WalletSdk
import circle.programmablewallet.sdk.api.ApiError
import circle.programmablewallet.sdk.api.Callback
import circle.programmablewallet.sdk.api.ExecuteWarning
import circle.programmablewallet.sdk.api.ExecuteEvent
import circle.programmablewallet.sdk.presentation.EventListener
import circle.programmablewallet.sdk.presentation.SecurityQuestion
import circle.programmablewallet.sdk.presentation.SettingsManagement
import circle.programmablewallet.sdk.result.ExecuteResult
import android.app.Application
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.TextView



class CircleWalletPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, Application.ActivityLifecycleCallbacks {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    private var sdkSetupDone = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "circle_wallet_android")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "circle_wallet_android/events"
        )
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                eventSink = sink
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        applicationContext?.let { setupSdkOnce(it) }
        
        // Register lifecycle callbacks to surgically hide "Forgot PIN?"
        val app = applicationContext as? Application
        app?.registerActivityLifecycleCallbacks(this)
    }



    // ActivityAware (required for SDK execute UI)
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val app = applicationContext as? Application
        app?.unregisterActivityLifecycleCallbacks(this)
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        applicationContext = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformName" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "execute" -> {
                handleExecute(call, result)
            }

            else -> result.notImplemented()
        }
    }


    private fun setupSdkOnce(appCtx: Context) {
        if (sdkSetupDone) return
        sdkSetupDone = true

        WalletSdk.setCustomUserAgent("FLUTTER-CIRCLE-WALLET")

        // Register icon provider — supplies white vector drawables for showPin,
        // hidePin, back, dropdownArrow so they are visible on the dark theme.
        WalletSdk.setViewSetterProvider(FlutterViewSetterProvider())

        WalletSdk.setLayoutProvider(FlutterWalletLayoutProvider(appCtx))

        // Listen for the forgotPin event and forward it via EventChannel stream.
        // Flutter subscribes to circle_wallet_android/events and filters on "forgotPin".
        WalletSdk.addEventListener(object : EventListener {
            override fun onEvent(event: ExecuteEvent) {
                if (event == ExecuteEvent.forgotPin) {
                    activity?.runOnUiThread {
                        eventSink?.success("forgotPin")
                    }
                }
            }
        })

        WalletSdk.setSecurityQuestions(
            arrayOf(
                SecurityQuestion("What is your father’s middle name?"),
                SecurityQuestion("What is your favorite sports team?"),
                SecurityQuestion("What is your mother’s maiden name?"),
                SecurityQuestion("What is the name of your first pet?"),
                SecurityQuestion("What is the name of the city you were born in?"),
                SecurityQuestion("What is the name of the first street you lived on?"),
                SecurityQuestion(
                    "When is your father’s birthday?",
                    SecurityQuestion.InputType.datePicker
                )
            )
        )
    }

    private val DEFAULT_ENDPOINT = "https://enduser-sdk.circle.com/v1/w3s/"

    private fun handleExecute(call: MethodCall, channelResult: Result) {
        val ctx = applicationContext
        val act = activity

        if (ctx == null) {
            channelResult.error("NO_CONTEXT", "Application context not available", null)
            return
        }
        if (act == null) {
            channelResult.error(
                "NO_ACTIVITY",
                "Activity not attached. execute() requires an Activity.",
                null
            )
            return
        }

        val appId = call.argument<String>("appId")
        val userToken = call.argument<String>("userToken")
        val encryptionKey = call.argument<String>("encryptionKey")
        val challengeId = call.argument<String>("challengeId")
        val enableBiometricsPin = call.argument<Boolean>("enableBiometricsPin") ?: false

        if (appId.isNullOrBlank() ||
            userToken.isNullOrBlank() ||
            encryptionKey.isNullOrBlank() ||
            challengeId.isNullOrBlank()
        ) {
            channelResult.error(
                "INVALID_ARGS",
                "Missing required args: appId, userToken, encryptionKey, challengeId",
                null
            )
            return
        }

        // Make sure we respond only once (SDK can call onWarning then onResult)
        var replied = false
        fun safeSuccess(payload: Map<String, Any?>) {
            if (replied) return
            replied = true
            channelResult.success(payload)
        }
        fun safeError(code: String, message: String?, details: Any?) {
            if (replied) return
            replied = true
            channelResult.error(code, message, details)
        }

        try {
            val settings = SettingsManagement().apply {
                isEnableBiometricsPin = enableBiometricsPin
            }

            WalletSdk.init(
                ctx,
                WalletSdk.Configuration(DEFAULT_ENDPOINT, appId, settings)
            )

            // 2) EXECUTE
            WalletSdk.execute(
                act,
                userToken,
                encryptionKey,
                arrayOf(challengeId),
                object : Callback<ExecuteResult> {

                    override fun onResult(result: ExecuteResult) {
                        safeSuccess(
                            mapOf(
                                "type" to "result",
                                "resultType" to result.resultType.name,
                                "status" to result.status.name,
                                "signature" to result.data.signature,
                                "signedTransaction" to result.data.signedTransaction,
                                "txHash" to result.data.txHash
                            )
                        )
                    }

                    override fun onError(error: Throwable): Boolean {
                        if (error is ApiError) {
                            safeError(
                                "SDK_ERROR",
                                error.message,
                                mapOf(
                                    "code" to error.code.value,
                                    "codeName" to error.code.name
                                )
                            )
                        } else {
                            safeError("SDK_ERROR", error.message, null)
                        }

                        // false = SDK finishes its Activity (matches sample behavior)
                        return false
                    }

                    override fun onWarning(warning: ExecuteWarning, result: ExecuteResult?): Boolean {
                        // Decide your policy:
                        // - If you want to treat warning as final (simple), respond and stop.
                        // - If you want warning + final result, you need an EventChannel.
                        safeSuccess(
                            mapOf(
                                "type" to "warning",
                                "warningType" to warning.name,
                                "warningMessage" to warning.warningString,
                                "partialResultType" to result?.resultType?.name,
                                "partialStatus" to result?.status?.name
                            )
                        )
                        return false
                    }
                }
            )
        } catch (t: Throwable) {
            safeError("EXECUTE_EXCEPTION", t.message, null)
        }
    }

    // region ActivityLifecycleCallbacks (Surgical UI Hiding)

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    
    override fun onActivityStarted(activity: Activity) {
        // When an SDK activity starts, try to hide the "Forgot PIN?" button immediately
        hideForgotPinButton(activity)
    }

    override fun onActivityResumed(activity: Activity) {
        // Re-check on resume just in case the view was re-inflated
        hideForgotPinButton(activity)
    }

    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}

    /**
     * Recursively searches for the "Forgot PIN?" button/text and hides it.
     */
    private fun hideForgotPinButton(activity: Activity) {
        val root = activity.findViewById<View>(android.R.id.content) ?: return
        if (root is ViewGroup) {
            findAndHideText(root, "Forgot PIN?")
        }
    }

    private fun findAndHideText(group: ViewGroup, targetText: String) {
        for (i in 0 until group.childCount) {
            val child = group.getChildAt(i)
            if (child is TextView) {
                val text = child.text?.toString()?.trim() ?: ""
                if (text.equals(targetText, ignoreCase = true)) {
                    child.visibility = View.GONE
                }
            } else if (child is ViewGroup) {
                findAndHideText(child, targetText)
            }
        }
    }
    // endregion
}