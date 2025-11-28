package com.example.qrcodedataextraction

import android.content.*
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import io.flutter.plugins.GeneratedPluginRegistrant;

//  This sample implementation is heavily based on the flutter demo at
//  https://github.com/flutter/flutter/blob/master/examples/platform_channel/android/app/src/main/java/com/example/platformchannel/MainActivity.java

class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "com.example.qrcodedataextraction/command"
    private val SCAN_CHANNEL = "com.example.qrcodedataextraction/scan"
    private val PROFILE_INTENT_ACTION = "com.example.qrcodedataextraction.SCAN"
    private val PROFILE_INTENT_BROADCAST = "2"

    private val dwInterface = DWInterface()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EventChannel(flutterEngine.dartExecutor, SCAN_CHANNEL).setStreamHandler(
            object : StreamHandler {
                private var dataWedgeBroadcastReceiver: BroadcastReceiver? = null
                override fun onListen(arguments: Any?, events: EventSink?) {
                    dataWedgeBroadcastReceiver = createDataWedgeBroadcastReceiver(events)
                    val intentFilter = IntentFilter()
                    intentFilter.addAction(PROFILE_INTENT_ACTION)
                    intentFilter.addAction(DWInterface.DATAWEDGE_RETURN_ACTION)
                    intentFilter.addCategory(DWInterface.DATAWEDGE_RETURN_CATEGORY)
                    registerReceiver(
                        dataWedgeBroadcastReceiver, intentFilter)
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(dataWedgeBroadcastReceiver)
                    dataWedgeBroadcastReceiver = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendDataWedgeCommandStringParameter")
            {
                val arguments = JSONObject(call.arguments.toString())
                val command: String = arguments.get("command") as String
                val parameter: String = arguments.get("parameter") as String
                dwInterface.sendCommandString(applicationContext, command, parameter)
                //  result.success(0);  //  DataWedge does not return responses
            }
            else if (call.method == "createDataWedgeProfile")
            {
                createDataWedgeProfile(call.arguments.toString())
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun createDataWedgeBroadcastReceiver(events: EventSink?): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == PROFILE_INTENT_ACTION) {
                    var scanData = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_DATA_STRING) ?: ""
                    var symbology = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_LABEL_TYPE) ?: ""

                    var date = Calendar.getInstance().getTime()
                    var df = SimpleDateFormat("dd/MM/yyyy HH:mm:ss")
                    var dateTimeString = df.format(date)

                    // **Handle RFID Scan**
                    var rfidTag = intent.getStringExtra("com.symbol.datawedge.rfid_string") ?: ""
                    if (rfidTag.isNotEmpty()) {
                        val rfidScan = Scan(rfidTag, "RFID", dateTimeString)
                        events?.success(rfidScan.toJson())
                    }

                    // **Handle Barcode Scan**
                    if (scanData.isNotEmpty()) {
                        val barcodeScan = Scan(scanData, symbology, dateTimeString)
                        events?.success(barcodeScan.toJson())
                    }
                }
            }
        }
    }


    private fun createDataWedgeProfile(profileName: String) {
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)

        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", profileName)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        // **1. Configure Barcode Scanner Plugin**
        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "true")
        val barcodeProps = Bundle()
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        // **2. Configure RFID Plugin**
        val rfidConfig = Bundle()
        rfidConfig.putString("PLUGIN_NAME", "RFID")
        rfidConfig.putString("RESET_CONFIG", "true")
        val rfidProps = Bundle()
        rfidProps.putString("rfid_enabled", "true")
        rfidConfig.putBundle("PARAM_LIST", rfidProps)
        profileConfig.putBundle("PLUGIN_CONFIG", rfidConfig)

        // **3. Associate Profile with the Flutter App**
        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))

        // Send the configuration to DataWedge
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        // **4. Configure Intent Output**
        profileConfig.remove("PLUGIN_CONFIG")
        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")
        val intentProps = Bundle()
        intentProps.putString("intent_category", "android.intent.category.DEFAULT")
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", PROFILE_INTENT_ACTION)
        intentProps.putString("intent_delivery", PROFILE_INTENT_BROADCAST)
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)

        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)
    }

}