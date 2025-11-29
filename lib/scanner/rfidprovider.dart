import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/data/apiservice.dart';
import 'package:qrcodedataextraction/data/containermodel.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_rfid_sdk_plugin.dart';

// --- 1. State Class to hold all data ---
class ScannerState {
  final String rawRfid;      // The long hex string from scanner
  final String tagLabel;     // The 'Tag_Lable' from API
  final bool isLoading;      // To show spinner during API call
  final String? errorMessage;

  ScannerState({
    this.rawRfid = "",
    this.tagLabel = "",
    this.isLoading = false,
    this.errorMessage,
  });

  ScannerState copyWith({
    String? rawRfid,
    String? tagLabel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScannerState(
      rawRfid: rawRfid ?? this.rawRfid,
      tagLabel: tagLabel ?? this.tagLabel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// --- 2. The Provider Definition ---
final rfidScanProvider = StateNotifierProvider.autoDispose<RfidScanNotifier, ScannerState>((ref) {
  return RfidScanNotifier();
});




// --- 3. The Controller Logic ---
class RfidScanNotifier extends StateNotifier<ScannerState> {
  RfidScanNotifier() : super(ScannerState()) {
    connectSdk();
  }

  void connectSdk() {
    ZebraRfidSdkPlugin.setEventHandler(ZebraEngineEventHandler(
      readRfidCallback: (datas) {
        if (datas.isNotEmpty) {
          String tagId = datas.first.tagID ?? "";
          // Only process if it's a new tag to avoid spamming API
          if (tagId != state.rawRfid) {
            _handleScannedTag(tagId);
          }
        }
      },
      errorCallback: (err) {
        state = state.copyWith(errorMessage: "Scanner Error: ${err.errorMessage}");
      },
      connectionStatusCallback: (status) {
        print("🔌 Connection Status: $status");
      },
    ));
    ZebraRfidSdkPlugin.connect();
  }

//   // Logic to handle scan and call API immediately
//   Future<void> _handleScannedTag(String rawTag) async {
//     // 1. Update state with raw tag and loading true
//     state = state.copyWith(rawRfid: rawTag, isLoading: true, errorMessage: null);
// 
//     try {
//       // 2. Call API to get Label
//       final data = await ApiService.getTagLabel(rawTag);
// 
//       if (data != null && data.containsKey('Tag_Lable')) {
//         // 3. Success: Update Tag Label
//         state = state.copyWith(
//           tagLabel: data['Tag_Lable'].toString(),
//           isLoading: false
//         );
//       } else {
//         state = state.copyWith(isLoading: false, errorMessage: "Tag not found in DB");
//       }
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: "API Failed");
//     }
//   }

Future<void> _handleScannedTag(String rawTag,) async {
  // Update state to loading
  state = state.copyWith(rawRfid: rawTag, isLoading: true, errorMessage: null);

  try {
    // API Call
    final data = await ApiService.getTagLabel(rawTag);

    if (data == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Something went wrong (null response)",
      );
      return;
    }

    // 1️⃣ Check ErrorMsg (BUT DO NOT STOP EXECUTION)
    final errorMsg = data["ErrorMsg"];
    if (data.containsKey("TagType") && data["TagType"] != null) {
  state = state.copyWith(
    errorMessage: data["TagType"].toString(), // use as popup message
  );
}

 if (data.containsKey("TagType") && data["TagType"] != null) {
void _showTagTypePopup(BuildContext context, String tagType) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Tag Type"),
      content: Text(tagType),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
    }
    // 2️⃣ Continue normally to Tag_Lable
    if (data.containsKey('Tag_Lable') && data['Tag_Lable'] != null) {
      state = state.copyWith(
        tagLabel: data['Tag_Lable'].toString(),
        isLoading: false,
      );
      return;
    }

    // 3️⃣ Tag_Lable missing? show fallback error
    state = state.copyWith(
      isLoading: false,
      errorMessage: state.errorMessage ?? "Tag not found in DB",
    );

  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: "API Failed",
    );
  }
}

  // Logic to Submit final data
Future<bool> submitData(ContainerModel model) async {

    // if (state.tagLabel.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    // Construct Payload
    final payload = {
      "ContNo": model.containerNo,
      "ContSizeId": model.sizeId, 
      "ContTypeId": model.typeId,  
      // "TagId": state.tagLabel, 
      "TagId": (state.tagLabel != null && state.tagLabel.trim().isNotEmpty)
    ? state.tagLabel
    : "00000000",
      "IsGateIn": true,
      "ActivityId": model.activityId,
      "ProcessId": model.processId,
      "IsActivePrioritize": model.isActivePrioritize,
      "Cont_Ref_no": model.containerRefNumber,
      "GateInType": 1,
      "Line_No": model.lineNo,
      "GateInBy": 1
    };

print("🚀 Submitting Data================: $payload");
    final success = await ApiService.submitContainerGateIn(payload);
    
    state = state.copyWith(isLoading: false);
    return success;
  
  }

  void disconnect() {
    ZebraRfidSdkPlugin.disconnect();
  }
}