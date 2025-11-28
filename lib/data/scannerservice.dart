import 'package:flutter/services.dart';

class RFIDService {
  static const platform = MethodChannel("com.yourapp/rfid");

  // Initialize RFID
  static Future<bool> initRFID() async {
    try {
      final result = await platform.invokeMethod("initRFID");
      print(result);
      return true;
    } catch (e) {
      print("Init Error: $e");
      return false;
    }
  }

  // Start scanning
  static Future<bool> startScan() async {
    try {
      final result = await platform.invokeMethod("startScan");
      print(result);
      return true;
    } catch (e) {
      print("Start Error: $e");
      return false;
    }
  }

  // Read EPC Tag from buffer
  static Future<String?> readTag() async {
    try {
      final epc = await platform.invokeMethod("readTag");
      return epc;
    } catch (e) {
      print("Read Error: $e");
      return null;
    }
  }

  // Stop scanning
  static Future<void> stopScan() async {
    await platform.invokeMethod("stopScan");
  }

  // Close RFID
  static Future<void> close() async {
    await platform.invokeMethod("closeRFID");
  }
}
