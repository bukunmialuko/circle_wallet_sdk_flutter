package com.example.verygoodcore

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
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
import circle.programmablewallet.sdk.presentation.SecurityQuestion
import circle.programmablewallet.sdk.presentation.SettingsManagement
import circle.programmablewallet.sdk.result.ExecuteResult


class CircleWalletPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    private var sdkSetupDone = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "circle_wallet_android")
        channel.setMethodCallHandler(this)
        applicationContext?.let { setupSdkOnce(it) }
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
        channel.setMethodCallHandler(null)
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
        val enableBiometricsPin = call.argument<Boolean>("enableBiometricsPin") ?: true

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
            // 1) INIT
            val settings = SettingsManagement().apply {
                isEnableBiometricsPin = enableBiometricsPin
                // disableConfirmationUI = ...
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


}