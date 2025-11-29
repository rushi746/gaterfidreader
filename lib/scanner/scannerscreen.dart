import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/data/containermodel.dart';
import 'package:qrcodedataextraction/scanner/rfidprovider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final ContainerModel containerModel;

  const ScannerScreen({super.key, required this.containerModel});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  // 1. ADD STATE VARIABLE
  bool _isEmptyContainer = false; // <--- CHANGE: Variable to track checkbox state

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(rfidScanProvider);
    final notifier = ref.read(rfidScanProvider.notifier);
    
    // Logic to determine if button is enabled
    // Enabled if: NOT loading AND (Tag is found OR Empty checkbox is checked)
    bool isButtonEnabled = !scannerState.isLoading && 
        (scannerState.tagLabel.isNotEmpty || _isEmptyContainer); // <--- CHANGE: Logic update

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
        title: const Text("Gate In Verification", style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background
          Positioned.fill(
            child: Image.asset('assets/Inner-bg.jpg', fit: BoxFit.cover),
          ),
          // 2. Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // --- SCROLLABLE CONTENT (Middle Part) ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        // --- SECTION 1: CONTAINER INFO ---
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
                              Text(widget.containerModel.containerNo, 
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold, 
                                  letterSpacing: 1
                                )
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  _buildBadge(widget.containerModel.size),
                                  const SizedBox(width: 8),
                                  _buildBadge(widget.containerModel.type),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- SECTION 2: RFID SCAN INFO ---
                        _buildSectionTitle("SCANNER STATUS"),
                        const SizedBox(height: 5),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: scannerState.tagLabel.isNotEmpty ? const Color(0xFFFF6D00) : Colors.white12, 
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
                                    Text("Pull trigger to scan", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    const Text("TAG LABEL", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(
                                      scannerState.tagLabel.isEmpty ? "FETCHING..." : scannerState.tagLabel,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6D00), 
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Divider(color: Colors.white24, height: 20),
                                    const Text("RAW RFID ID", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                    Text(
                                      scannerState.rawRfid,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Courier'),
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
                            child: Text(
                              scannerState.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // --- 3. NEW CHECKBOX SECTION --- 
                        Container( // <--- CHANGE: Added Container for styling
                           decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _isEmptyContainer ? Colors.orangeAccent : Colors.white12),
                          ),
                          child: CheckboxListTile(
                            title: const Text(
                              "Empty Container (No Tag)",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Check this if Container has no RFID tag",
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            value: _isEmptyContainer,
                            activeColor: const Color(0xFFFF6D00),
                            checkColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            onChanged: (bool? value) {
                              setState(() {
                                _isEmptyContainer = value ?? false;
                              });
                            },
                          ),
                        ),
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
                      // 4. UPDATE BUTTON LOGIC
                      onPressed: isButtonEnabled // <--- CHANGE: Using the boolean logic defined at top
                          ? () async {
                              // NOTE: You might need to update submitData to handle 
                              // cases where tagLabel is empty but _isEmptyContainer is true.
                              final success = await notifier.submitData(widget.containerModel);
                              
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Gate In Successful!"), backgroundColor: Colors.green)
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
                        elevation: 5,
                      ),
                      child: scannerState.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "SUBMIT ENTRY",
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

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}