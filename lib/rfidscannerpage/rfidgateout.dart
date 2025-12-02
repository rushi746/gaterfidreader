import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_rfid_sdk_plugin.dart';
import 'package:qrcodedataextraction/data/apiservice.dart'; // Ensure correct path

// ==========================================
// 1. STATE CLASS
// ==========================================
class ScannerState {
  final String rawRfid;      // The long hex string (e.g., 0000...39)
  final String tagLabel;     // The short ID (e.g., 18082609)
  final bool isLoading;
  final String? errorMessage;
  
  // Data fetched from Gate Out API
  final int? masterId;
  final String? containerNo;
  final String? containerSize;
  final String? containerType;

  ScannerState({
    this.rawRfid = "",
    this.tagLabel = "",
    this.isLoading = false,
    this.errorMessage,
    this.masterId,
    this.containerNo,
    this.containerSize,
    this.containerType,
  });

  ScannerState copyWith({
    String? rawRfid,
    String? tagLabel,
    bool? isLoading,
    String? errorMessage,
    int? masterId,
    String? containerNo,
    String? containerSize,
    String? containerType,
  }) {
    return ScannerState(
      rawRfid: rawRfid ?? this.rawRfid,
      tagLabel: tagLabel ?? this.tagLabel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      masterId: masterId ?? this.masterId,
      containerNo: containerNo ?? this.containerNo,
      containerSize: containerSize ?? this.containerSize,
      containerType: containerType ?? this.containerType,
    );
  }
}

// ==========================================
// 2. PROVIDER
// ==========================================
final rfidScanProviderGateout = StateNotifierProvider.autoDispose<RfidScanNotifier, ScannerState>((ref) {
  return RfidScanNotifier();
});

// ==========================================
// 3. NOTIFIER (LOGIC)
// ==========================================
class RfidScanNotifier extends StateNotifier<ScannerState> {
  RfidScanNotifier() : super(ScannerState()) {
    connectSdk();
  }

  void connectSdk() {
    ZebraRfidSdkPlugin.setEventHandler(ZebraEngineEventHandler(
      readRfidCallback: (datas) {
        if (datas.isNotEmpty) {
          String tagId = datas.first.tagID ?? "";
          // Avoid repeated calls for the same tag while loading
          if (tagId != state.rawRfid && !state.isLoading) {
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

  // ✅ LOGIC UPDATED: Chain API calls
  Future<void> _handleScannedTag(String rawTag) async {
    print("🔔 Scanner Event: New Tag Scanned -> $rawTag");
    
    // Set loading and raw tag immediately
    state = state.copyWith(rawRfid: rawTag, isLoading: true, errorMessage: null);

    try {
      // --- STEP 1: Get Tag Label ---
      print("🔹 Step 1: Fetching Label for Raw Tag: $rawTag");
      final labelResponse = await ApiService.getTagLabel(rawTag);

      if (labelResponse == null) {
        print("❌ Step 1 Failed: API returned null");
        state = state.copyWith(isLoading: false, errorMessage: "Failed to fetch Tag Label");
        return;
      }

      if (!labelResponse.containsKey('Tag_Lable') || labelResponse['Tag_Lable'] == null) {
        print("❌ Step 1 Failed: 'Tag_Lable' key missing or null");
        state = state.copyWith(isLoading: false, errorMessage: "Tag Label not found in Database");
        return;
      }

      String resolvedLabel = labelResponse['Tag_Lable'].toString();
      print("✅ Step 1 Success: Resolved Label -> $resolvedLabel");

      // Update state with the resolved label (UI will update)
      state = state.copyWith(tagLabel: resolvedLabel);

      // --- STEP 2: Get Gate Out Details using Resolved Label ---
      print("🔹 Step 2: Fetching Gate Out Details for Label: $resolvedLabel");
      final gateOutResponse = await ApiService.getGateOutDetail(resolvedLabel);

      if (gateOutResponse != null && gateOutResponse['data'] != null) {
        List<dynamic> dataList = gateOutResponse['data'];
        
        if (dataList.isNotEmpty) {
          final item = dataList[0];
          print("✅ Step 2 Success: Data Found -> $item");
          
          state = state.copyWith(
            isLoading: false,
            masterId: item['Master_Id'],
            containerNo: item['Cont_No'] ?? "Unknown",
            containerSize: item['Cont_Size']?.toString() ?? "-",
            containerType: item['Cont_Type'] ?? "-",
            errorMessage: null,
          );
        } else {
          print("⚠️ Step 2 Warning: Data list is empty");
          state = state.copyWith(
            isLoading: false, 
            errorMessage: "No Gate Out details found for Label: $resolvedLabel"
          );
        }
      } else {
        print("❌ Step 2 Failed: Response null or invalid");
        state = state.copyWith(
          isLoading: false, 
          errorMessage: "Failed to fetch Container Details."
        );
      }
    } catch (e) {
      print("❌ Exception in Process: $e");
      state = state.copyWith(
        isLoading: false, 
        errorMessage: "Error: $e"
      );
    }
  }

  Future<bool> submitData() async {
    if (state.masterId == null) {
      state = state.copyWith(errorMessage: "No Container Data to submit.");
      return false;
    }
    
    // Ensure we have the label
    if (state.tagLabel.isEmpty) {
       state = state.copyWith(errorMessage: "Tag Label is missing.");
       return false;
    }

    state = state.copyWith(isLoading: true);
    print("🔹 Submitting Gate Out Data...");

    // Call the Gate Out Submit API
    final success = await ApiService.submitGateOut(
      masterId: state.masterId!,
      gateOutBy: 1, 
      gateOutType: 1, 
      tagLabel: state.tagLabel, // Sending the resolved label (e.g., 18082609)
    );
    
    print("🔔 Submit Result: $success");
    state = state.copyWith(isLoading: false);
    return success;
  }

  void disconnect() {
    print("🔌 Disconnecting Scanner...");
    ZebraRfidSdkPlugin.disconnect();
  }
}

// ==========================================
// 4. UI SCREEN
// ==========================================
class GateOutscanner extends ConsumerStatefulWidget {
  const GateOutscanner({super.key});

  @override
  ConsumerState<GateOutscanner> createState() => _GateOutscannerState();
}

class _GateOutscannerState extends ConsumerState<GateOutscanner> {

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(rfidScanProviderGateout);
    final notifier = ref.read(rfidScanProviderGateout.notifier);
    
    bool isButtonEnabled = !scannerState.isLoading && scannerState.masterId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
             notifier.disconnect();
             Navigator.pop(context);
          },
        ),
        title: const Text("Gate OUT Verification", style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Inner-bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        _buildSectionTitle("SCANNER STATUS"),
                        const SizedBox(height: 5),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: scannerState.rawRfid.isNotEmpty ? const Color(0xFFFF6D00) : Colors.white12, 
                              width: 2
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (scannerState.isLoading)
                                const SizedBox(
                                  height: 40, width: 40,
                                  child: CircularProgressIndicator(color: Color(0xFFFF6D00), strokeWidth: 3),
                                )
                              else if (scannerState.rawRfid.isEmpty)
                                Column(
                                  children: [
                                    Icon(Icons.qr_code_scanner, size: 40, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text("Pull trigger to scan Gate Out Tag", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    const Text("RESOLVED LABEL", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(
                                      scannerState.tagLabel.isEmpty ? "FETCHING..." : scannerState.tagLabel,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6D00), 
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Divider(color: Colors.white24, height: 20),
                                    const Text("RAW RFID", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                    Text(
                                      scannerState.rawRfid,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: "Courier"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        if (scannerState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                border: Border.all(color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Text(
                                scannerState.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),
                        
                        if (scannerState.masterId != null) ...[
                          _buildSectionTitle("CONTAINER DETAILS"),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Container Number", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                Text(scannerState.containerNo ?? "N/A", 
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 1
                                  )
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    _buildInfoBox("Size", scannerState.containerSize ?? "-"),
                                    Container(width: 1, height: 30, color: Colors.white24),
                                    _buildInfoBox("Type", scannerState.containerType ?? "-"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: const Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () async {
                              final success = await notifier.submitData();
                              
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Gate Out Successful!"), backgroundColor: Colors.green)
                                );
                                Navigator.pop(context);
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Submission Failed. Check logs."), backgroundColor: Colors.red)
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6D00),
                        disabledBackgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 5,
                      ),
                      child: scannerState.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "CONFIRM GATE OUT",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.orangeAccent.withOpacity(0.8),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}