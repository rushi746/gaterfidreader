import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qrcodedataextraction/data/containermodel.dart';

class ApiService {
  static const String baseUrl = "http://qikkle.com/Eklavya_GDLRFID";
  static const String baseUrl1 = "http://103.25.130.254/gdltestapi/api";
static const String apiUrl = "http://qikkle.com/Eklavya_GDLRFID/GateIn/PendingContainerByGate?GateInType=1&UserId=1";
  // LOGIN API CALL
  static Future<http.Response> loginUser(String username, String password) async {
    // Convert to Base64
    String encodedUser = base64Encode(utf8.encode(username));
    String encodedPass = base64Encode(utf8.encode(password));

    final url = Uri.parse("$baseUrl/Account/ValidateUser");

    final body = jsonEncode({
      "UserName": encodedUser,
      "Password": encodedPass,
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    return response;
  }

  static Future<List<ContainerModel>> fetchPendingContainers() async {
    try {
      final Uri url = Uri.parse(apiUrl);
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList.map((json) => ContainerModel.fromJson(json)).toList();
      } else {
        print("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }
 // --- API 1: Get Tag Label from Scanned RFID ---
  static Future<Map<String, dynamic>?> getTagLabel(String tag) async {
    try {
      final url = Uri.parse("$baseUrl/TagMaster/GetTagLable");
      final body = jsonEncode({"tag": tag});
print("📤 Request Body for Tag Label: $body");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print("✅ Get Tag Label Success=========: ${response.body}");
        return jsonDecode(response.body);
      } else {
        print("❌ API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Get Tag Label Exception: $e");
      rethrow;
    }
  }

  // --- API 2: Submit Container Gate In ---
  static Future<bool> submitContainerGateIn(Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse("$baseUrl/GateIn/ContainerGateInDetail");
      
      print("📤 Submitting Payload: $payload");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
       print("✅ Submit Success=======================: ${response.body}"); 

        return true;
      } else {
        print("❌ Submit Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Gate In API Exception: $e");
      return false;
    }
  }
// ======================= GATE OUT APIs =======================

static Future<Map<String, dynamic>?> getGateOutDetail(String tag) async {
  try {
    final url = Uri.parse("$baseUrl/GateOut/GetContainerGateOutDetail");

    final body = jsonEncode({
      "ContainerTag": tag,
    });
   
    print("📤 GateOut Detail Request: $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("📥 GateOut Detail Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ GateOut Detail Error Code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("❌ GateOut Detail Exception: $e");
    return null;
  }
}


// ----------- Submit Container GATE OUT ----------
static Future<bool> submitGateOut({
  required int masterId,
  required int gateOutBy,
  required int gateOutType,
  required String tagLabel,
}) async {
  try {
    final url = Uri.parse("$baseUrl/GateOut/ContainerGateOut");

    final payload = {
      "Master_Id": masterId,
      "Gate_Out_By": gateOutBy,
      "GateOutType": gateOutType,
      "TagLable": tagLabel,
    };

    print("📤 GateOut Submit Payload: $payload");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    print("📥 GateOut Submit Response: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ GateOut Submit Error Code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ GateOut Submit Exception: $e");
    return false;
  }
}

}
