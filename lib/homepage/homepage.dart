import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrcodedataextraction/data/containermodel.dart';
import 'package:qrcodedataextraction/homepage/homecontroller.dart';
import 'package:qrcodedataextraction/loginpage/loginpage.dart';
import 'package:qrcodedataextraction/scanner/scannerscreen.dart'; 
import '../main.dart'; 

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerList = ref.watch(homeProvider);

    // Define Industrial Orange Color
    const Color primaryOrange = Color(0xFFFF6D00);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Inner-bg.jpg', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF212121)),
            ),
          ),

          // 2. Heavy Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Premium Header with Logout ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 24, 
                                width: 4, 
                                decoration: BoxDecoration(
                                  color: primaryOrange,
                                  borderRadius: BorderRadius.circular(2)
                                )
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "TagTrackr",
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 24, 
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Text(
                              "Operations Dashboard", 
                              style: TextStyle(color: Colors.white70, fontSize: 12)
                            ),
                          ),
                        ],
                      ),
                      
                      // Right Side Actions
                      Row(
                        children: [
                          // Pending Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              "${containerList.length} Pending",
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // --- LOGOUT BUTTON ---
                          InkWell(
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2), // Light Red tint
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                              ),
                              child: const Icon(Icons.logout, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // --- List View ---
                Expanded(
                  child: containerList.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white54, size: 60),
                              SizedBox(height: 10),
                              Text("All Tasks Completed", style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        )
                      : 
Expanded(
  child: RefreshIndicator(
    onRefresh: () async {
      await ref.read(homeProvider.notifier).refreshList();
    },
    color: Colors.orangeAccent,
    backgroundColor: Colors.white,

    child: containerList.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Icon(Icons.check_circle_outline, color: Colors.white54, size: 60),
              SizedBox(height: 10),
              Center(
                child: Text("All Tasks Completed",
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          )

        : ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: containerList.length,
            itemBuilder: (context, index) {
              return _buildIndustrialCard(
                context,
                containerList[index],
                const Color(0xFFFF6D00),
              );
            },
          ),
  ),
)

               
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Logout Dialog Function ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to exit?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
           onPressed: () {
  final box = GetStorage();
  box.erase(); // 🧹 Clear all saved data

  Navigator.pop(context); // Close dialog

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,   // Remove all previous routes
  );
},

            child: const Text("Logout", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- CARD WIDGET (Same as before) ---
  Widget _buildIndustrialCard(BuildContext context, ContainerModel item, Color primaryColor) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: primaryColor.withOpacity(0.1),
            highlightColor: primaryColor.withOpacity(0.05),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
              builder: (context) => ScannerScreen(containerModel: item),

                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: primaryColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.inventory_2, color: primaryColor, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CONTAINER ID",
                                  style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item.containerNo,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF212121)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _tag(item.size + "'", Colors.orange[50]!, Colors.orange[900]!, Icons.straighten),
                                    const SizedBox(width: 8),
                                    _tag(item.type, Colors.grey[100]!, Colors.grey[800]!, Icons.category),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFF6D00).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                              ]
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                 builder: (context) => ScannerScreen(containerModel: item),
                                  ),
                                );
                             
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg, Color textCol, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textCol.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol)),
        ],
      ),
    );
  }
}