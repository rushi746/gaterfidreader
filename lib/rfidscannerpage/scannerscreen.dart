import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/rfidscannerpage/rfidgateout.dart';
// import path to your updated rfid_provider.dart

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

    // Button is enabled if we have a Master_Id (fetched from API) and not loading
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
                        
                        // --- SECTION 1: SCANNER STATUS ---
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
                            children: [
                              if (scannerState.isLoading)
                                const SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: Color(0xFFFF6D00)))
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
                                    const Text("SCANNED TAG", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(
                                      scannerState.rawRfid,
                                      style: const TextStyle(color: Color(0xFFFF6D00), fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Error Message
                        if (scannerState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                scannerState.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),

                        // --- SECTION 2: FETCHED DETAILS (Only show if we have data) ---
                        if (scannerState.masterId != null) ...[
                          _buildSectionTitle("CONTAINER DETAILS"),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Container No", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                Text(
                                  scannerState.containerNo ?? "N/A", 
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildInfoBox("Size", scannerState.containerSize ?? "-"),
                                    const SizedBox(width: 15),
                                    _buildInfoBox("Type", scannerState.containerType ?? "-"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // --- SUBMIT BUTTON ---
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
                                  const SnackBar(content: Text("Submission Failed"), backgroundColor: Colors.red)
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6D00),
                        disabledBackgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: scannerState.isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SUBMIT GATE OUT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      style: TextStyle(color: Colors.orangeAccent.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}