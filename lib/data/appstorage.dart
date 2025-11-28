import 'package:get_storage/get_storage.dart';

class AppStorage {
  static GetStorage box() => GetStorage();

  static Future<void> saveLoginResult(dynamic result) async {
    await box().write("loginResult", result);
  }

  static dynamic getLoginResult() {
    return box().read("loginResult");
  }

  static Future<void> clearLogin() async {
    await box().remove("loginResult");
  }
}
