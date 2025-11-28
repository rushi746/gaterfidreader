import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/data/apiservice.dart';
import '../data/containermodel.dart';

class HomeController extends StateNotifier<List<ContainerModel>> {
  Timer? _timer;

  HomeController() : super([]) {
    loadData();          // initial load
    startAutoRefresh();  // auto refresh
  }

  // --- Load Data from API ---
  Future<void> loadData() async {
    try {
      List<ContainerModel> newData = await ApiService.fetchPendingContainers();

      state = newData.isNotEmpty ? newData : [];
    } catch (e) {
      // Optional: Handle error
      print("🔴 Fetch error: $e");
    }
  }

  // --- Auto Refresh Every 30 Seconds ---
  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      loadData();
      print("🔄 Auto Refresh Triggered");
    });
  }

  // Stop timer when provider disposed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refreshList() async {
    await loadData();
  }
}

// Provider
final homeProvider =
    StateNotifierProvider<HomeController, List<ContainerModel>>((ref) {
  return HomeController();
});
