class ContainerModel {
  final String containerNo;
  final String size;
  final String type;

  final int sizeId;
  final int typeId;
  final int activityId;

  final int processId;
  final String lineNo;
  final String containerRefNumber;
  final bool isActivePrioritize;

  ContainerModel({
    required this.containerNo,
    required this.size,
    required this.type,

    this.sizeId = 0,
    this.typeId = 0,
    this.activityId = 0,

    this.processId = 0,
    this.lineNo = "",
    this.containerRefNumber = "",
    this.isActivePrioritize = false,
  });

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      containerNo: json['Cont_No']?.toString() ?? "N/A",
      size: json['Cont_Size']?.toString() ?? "0",
      type: json['Cont_Type']?.toString() ?? "GEN",

      sizeId: json['Size_Id'] ?? 0,
      typeId: json['Type_Id'] ?? 0,
      activityId: json['Activity_Id'] ?? 0,

      processId: json['Process_Id'] ?? 0,
      lineNo: json['Line']?.toString() ?? "",
      containerRefNumber: json['Cont_ref_no']?.toString() ?? "",

      // API me nahi aata, so default
    );
  }
}
