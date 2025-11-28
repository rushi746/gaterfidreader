import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcodedataextraction/data/apiservice.dart';
import '../data/containermodel.dart';

class HomeController extends StateNotifier<List<ContainerModel>> {
  HomeController() : super([]) {
    loadData();
  }

  // --- Real Data Loading ---
  Future<void> loadData() async {
    List<ContainerModel> newData = await ApiService.fetchPendingContainers();
    
    if (newData.isNotEmpty) {
      state = newData; 
    } else {
      state = [];
    }
  }

  Future<void> refreshList() async {
    await loadData();
  }
}

// Provider (UI isko listen karega)
final homeProvider = StateNotifierProvider<HomeController, List<ContainerModel>>((ref) {
  return HomeController();
});