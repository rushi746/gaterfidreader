class ContainerModel {
  final String containerNo;
  final String size;       // Display: "40"
  final String type;       // Display: "HC"
  
  // --- NEW FIELDS FOR API SUBMISSION ---
  final int sizeId;        // Backend ID: 3
  final int typeId;        // Backend ID: 5
  final int activityId;    // Backend ID: 5

  ContainerModel({
    required this.containerNo,
    required this.size,
    required this.type,
    // Initialize defaults
    this.sizeId = 0,
    this.typeId = 0,
    this.activityId = 0,
  });

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      containerNo: json['Cont_No']?.toString() ?? "N/A",
      size: json['Cont_Size']?.toString() ?? "0",
      type: json['Cont_Type']?.toString() ?? "GEN",
      
      // --- Capture IDs from JSON ---
      sizeId: json['Size_Id'] ?? 0,
      typeId: json['Type_Id'] ?? 0,
      activityId: json['Activity_Id'] ?? 0,
    );
  }
}