import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/helpers/consts.dart';

class sessionController extends GetxController {
  static final FlutterSecureStorage storage = FlutterSecureStorage();
  Future<String?> readRole() async {
    String? role = await storage.read(key: USER_ROLE);
    print("ROLE ROLE ROLE : $role");
    return role;
  }

  Future<String?> readToken() async {
    String? token = await storage.read(key: ACCESS_TOKEN);
    print("TOOOOKKKKKEENNNN : $token");
    return token;
  }

  Future<String?> readId() async {
    String? idUser = await storage.read(key: USER_ID);
    print("ID USER ID USER ID USER  : $idUser");

    return idUser;
  }

  Future<void> writeRole(String valueparam) async {
    await storage.write(key: USER_ROLE, value: valueparam);
  }

  Future<void> writeToken(String valueparam) async {
    await storage.write(key: ACCESS_TOKEN, value: valueparam);
  }

  Future<void> writeId(String valueparam) async {
    await storage.write(key: USER_ID, value: valueparam);
  }

  Future<void> writeRefToken(String valueparam) async {
    await storage.write(key: REFRESH_TOKEN, value: valueparam);
  }

  Future<void> deleteSession() async {
    storage.deleteAll();
  }
}
