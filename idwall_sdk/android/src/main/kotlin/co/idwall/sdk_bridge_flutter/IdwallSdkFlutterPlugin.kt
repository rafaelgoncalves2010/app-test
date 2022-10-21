package co.idwall.sdk_bridge_flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import co.idwall.sdk.core.SdkConfig
import co.idwall.sdk.core.utils.log.LoggingLevel
import co.idwall.sdk.document.DocumentRequest
import co.idwall.sdk.liveness.LivenessRequest
import co.idwall.sdk.metrics.events.IdwallEvent
import co.idwall.sdk.metrics.events.IdwallEventsHandler
import co.idwall.toolkit.IDwallToolkit
import co.idwall.toolkit.core.DocType
import co.idwall.toolkit.core.RequestResponse
import co.idwall.toolkit.flow.core.Doc
import co.idwall.toolkit.flow.core.Flow
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar

import org.json.JSONObject

/** IdwallSdkFlutterPlugin */
public class IdwallSdkFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventsChannel: BasicMessageChannel<Any>
    private var currentActivity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var currentResult: Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "idwall_sdk")
        channel.setMethodCallHandler(this);

        eventsChannel = BasicMessageChannel(flutterPluginBinding.flutterEngine.dartExecutor, "idwall_sdk_events", JSONMessageCodec.INSTANCE)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "idwall_sdk")
            channel.setMethodCallHandler(IdwallSdkFlutterPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.currentResult = result
        when (call.method) {
            "initialize" -> initialize(call.arguments as String)
            "initializeWithLoggingLevel" -> {
                val args = call.arguments as ArrayList<String>
                initializeWithLoggingLevel(args[0], args[1])
            }
            "startLivenessFlow" -> startLivenessFlow()
            "startDocumentFlow" -> startDocumentFlow(call.arguments as String)
            "startCompleteFlow" -> startCompleteFlow(call.arguments as String)
            "requestLiveness" -> requestLiveness()
            "requestDocument" -> {
                val args = call.arguments as ArrayList<String>
                requestDocument(args[0], args[1])
            }
            "showTutorialBeforeDocumentCapture" -> showTutorialBeforeDocumentCapture(call.arguments as Boolean)
            "showTutorialBeforeLiveness" -> showTutorialBeforeLiveness(call.arguments as Boolean)
            "enableLivenessFallback" -> enableLivenessFallback(call.arguments as Boolean)
            "sendLivenessData" -> sendLivenessData()
            "sendDocumentData" -> sendDocumentData(call.arguments as String)
            "sendCnhWithLivenessData" -> sendCnhWithLivenessData()
            "sendRgWithLivenessData" -> sendRgWithLivenessData()
            "sendCrlvWithLivenessData" -> sendCrlvWithLivenessData()
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun sendCrlvWithLivenessData() {
        val docTypes = mutableListOf(DocType.CRLV, DocType.LIVENESS_FRAME_SERIOUS, DocType.LIVENESS_FRAME_SMILE)

        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("-1", error, null)
            }

            override fun onProgress(progress: Float) {
            }

        }, docTypes)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK && requestCode == IDwallToolkit.IDWALL_REQUEST) {
            if (data?.extras?.containsKey(IDwallToolkit.TOKEN) == true) {
                try {
                    data.getStringExtra(IDwallToolkit.TOKEN)?.let { token ->
                        currentResult?.success(token)
                        return true
                    }
                    currentResult?.error("-1", "Error while creating token", null)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            } else {
                currentResult?.error("-1", "Flow cancelled by user", null)
            }
        } else if (resultCode == Activity.RESULT_OK && (requestCode == LivenessRequest.REQUEST_CODE || requestCode == DocumentRequest.REQUEST_CODE)) {
            currentResult?.success(true)
        } else {
            currentResult?.error("-1", "Flow cancelled by user", null)
        }
        this.activityBinding?.removeActivityResultListener(this)
        return true
    }

    fun initialize(authKey: String) {
        IDwallToolkit.getInstance().init(currentActivity?.application, authKey)
        SdkConfig.appPlatform = "flutter"
        SdkConfig.bridgeVersion = BuildConfig.BRIDGE_VERSION
        configEventsHandler()
    }

    fun initializeWithLoggingLevel(authKey: String, loggingLevel: String = "") {
        val nativeLoggingLevel = getNativeLoggingLevel(loggingLevel)

        if (nativeLoggingLevel == null) {
            currentResult?.error("-1", "Unsupported logging level.", null)
            return
        }

        IDwallToolkit.getInstance().init(currentActivity?.application, authKey, nativeLoggingLevel)
        SdkConfig.appPlatform = "flutter"
        SdkConfig.bridgeVersion = BuildConfig.BRIDGE_VERSION
        configEventsHandler()
    }

    fun startLivenessFlow() {
        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().startFlow(currentActivity, Flow.LIVENESS)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun startDocumentFlow(documentType: String) {
        val doc = getDocFromString(documentType)

        if (doc == null) {
            currentResult?.error("-1", "Unsupported document type.", null)
            return
        }

        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().startFlow(currentActivity, Flow.DOC, doc)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun startCompleteFlow(documentType: String) {
        val doc = getDocFromString(documentType)

        if (doc == null) {
            currentResult?.error("-1", "Unsupported document type.", null)
            return
        }

        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().startFlow(currentActivity, Flow.COMPLETE, doc)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun requestDocument(documentType: String, documentSide: String) {
        val docType = getNativeDocType(documentType, documentSide)

        if (docType == null) {
            currentResult?.error("-1", "Unsupported document type or side.", null)
            return
        }

        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().requestDocument(currentActivity, docType)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun requestLiveness() {
        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().requestLiveness(currentActivity)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun sendLivenessData() {
        val livenessDocTypes = mutableListOf(DocType.LIVENESS_FRAME_SERIOUS, DocType.LIVENESS_FRAME_SMILE)

        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("-1", error, null)
            }

            override fun onProgress(progress: Float) {
            }

        }, livenessDocTypes)
    }

    fun sendDocumentData(documentType: String) {
        val docTypes = getNativeDocTypesToSend(documentType)

        if (docTypes == null) {
            currentResult?.error("-1", "Unsupported document type or side.", null)
            return
        }

        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("idwallSendError", error, null)
            }

            override fun onProgress(progress: Float) {
            }

        }, docTypes)
    }

    fun sendRgWithLivenessData() {
        val docTypes = mutableListOf(DocType.RG_BACK, DocType.RG_FRONT, DocType.LIVENESS_FRAME_SERIOUS, DocType.LIVENESS_FRAME_SMILE)

        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("-1", error, null)
            }

            override fun onProgress(progress: Float) {
            }

        }, docTypes)
    }

    fun sendCnhWithLivenessData() {
        val docTypes = mutableListOf(DocType.CNH, DocType.LIVENESS_FRAME_SERIOUS, DocType.LIVENESS_FRAME_SMILE)

        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("-1", error, null)
            }

            override fun onProgress(progress: Float) {

            }
        }, docTypes)
    }

    fun enableLivenessFallback(enabled: Boolean) {
        IDwallToolkit.getInstance().enableLivenessFallback(enabled)
    }

    fun showTutorialBeforeDocumentCapture(showTutorial: Boolean) {
        IDwallToolkit.getInstance().showTutorialBeforeDocumentCapture(showTutorial)
    }

    fun showTutorialBeforeLiveness(showTutorial: Boolean) {
        IDwallToolkit.getInstance().showTutorialBeforeLiveness(showTutorial)
    }

    private fun getNativeLoggingLevel(loggingLevel: String): LoggingLevel? {
        return when (loggingLevel) {
            "MINIMAL" -> LoggingLevel.MINIMAL
            "REGULAR" -> LoggingLevel.REGULAR
            "VERBOSE" -> LoggingLevel.VERBOSE
            else -> null
        }
    }

    private fun getNativeDocTypesToSend(documentType: String): List<DocType>? {
        when (documentType) {
            "CNH" -> {
                return listOf(DocType.CNH)
            }
            "CRLV" -> {
                return listOf(DocType.CRLV)
            }
            "RG" -> {
                return listOf(DocType.RG_FRONT, DocType.RG_BACK)
            }
            "POA" -> {
                return listOf(DocType.PROOF_OF_ADDRESS_FRONT, DocType.PROOF_OF_ADDRESS_BACK)
            }
            "TYPIFIED" -> {
                return listOf(DocType.TYPIFIED_FRONT, DocType.TYPIFIED_BACK)
            }
            "GENERIC" -> {
                return listOf(DocType.GENERIC)
            }
            "GENERIC_FRONT_BACK" -> {
                return listOf(DocType.GENERIC_FRONT, DocType.GENERIC_BACK)
            }
        }
        return null
    }

    private fun getNativeDocType(documentType: String, documentSide: String): DocType? {
        if (documentSide != "FRONT" && documentSide != "BACK") {
            return null
        }

        when (documentType) {
            "CNH" -> {
                return if (documentSide == "FRONT") {
                    DocType.CNH
                } else {
                    null
                }
            }
            "CRLV" -> {
                return if (documentSide == "FRONT") {
                    DocType.CRLV
                } else {
                    null
                }
            }
            "RG" -> {
                return if (documentSide == "FRONT") {
                    DocType.RG_FRONT
                } else {
                    DocType.RG_BACK
                }
            }
            "POA" -> {
                return if (documentSide == "FRONT") {
                    DocType.PROOF_OF_ADDRESS_FRONT
                } else {
                    DocType.PROOF_OF_ADDRESS_BACK
                }
            }
            "TYPIFIED" -> {
                return if (documentSide == "FRONT") {
                    DocType.TYPIFIED_FRONT
                } else {
                    DocType.TYPIFIED_BACK
                }
            }
            "GENERIC" -> {
                return if (documentSide == "FRONT") {
                    DocType.GENERIC
                } else {
                    null
                }
            }
            "GENERIC_FRONT_BACK" -> {
                return if (documentSide == "FRONT") {
                    DocType.GENERIC_FRONT
                } else {
                    DocType.GENERIC_BACK
                }
            }
        }
        return null
    }

    private fun getDocFromString(documentType: String): Doc? {
        return when (documentType) {
            "CHOOSE" -> Doc.CHOOSE
            "CNH" -> Doc.CNH
            "CRLV" -> Doc.CRLV
            "RG" -> Doc.RG
            "POA" -> Doc.PROOF_OF_ADDRESS_FRONT_BACK
            "TYPIFIED" -> Doc.TYPIFIED_FRONT_BACK
            "GENERIC" -> Doc.GENERIC
            "GENERIC_FRONT_BACK" -> Doc.GENERIC_FRONT_BACK
            else -> null
        }
    }

    private fun configEventsHandler() {
        IDwallToolkit.getInstance().setEventsHandler(object : IdwallEventsHandler {
            override fun onEvent(event: IdwallEvent) {
                currentActivity?.runOnUiThread {
                    val idwallEvent = JSONObject()
                    idwallEvent.put("name", event.name)
                    val propMap = JSONObject()
                    for (prop in event.properties) {
                        propMap.put(prop.key, prop.value)
                    }
                    idwallEvent.put("properties", propMap)
                    eventsChannel.send(idwallEvent)
                }
            }
        })
    }

    override fun onDetachedFromActivity() {
        this.activityBinding?.removeActivityResultListener(this)
        this.currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.currentActivity = binding.activity
        this.activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
