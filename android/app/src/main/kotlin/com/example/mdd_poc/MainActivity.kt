package com.example.mdd_poc

import com.example.mdd_poc.mdm.channel.MdmMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/** Connects Flutter to the native MDM handler; contains no MDM logic. */
class MainActivity : FlutterActivity() {
    private var mdmChannel: MdmMethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mdmChannel = MdmMethodChannel.register(
            context = applicationContext,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        mdmChannel?.dispose()
        mdmChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
