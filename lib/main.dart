import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/admin_controller.dart';
import 'package:helpdesk/src/controllers/chat_controller.dart';

import 'package:helpdesk/src/controllers/editequipement_controller.dart';
import 'package:helpdesk/src/controllers/equipement_controller.dart';
import 'package:helpdesk/src/controllers/search_controller.dart' as custom;
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/controllers/technician_controller.dart';
import 'package:helpdesk/src/controllers/ticket_controller.dart';

import 'src/controllers/user_controller.dart';
import 'src/helpers/consts.dart';
import 'src/routes/Approutes.dart';
import 'src/service/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(sessionController());
  Get.put(UserController());
  Get.put(AdminController());
  Get.put(SocketService());
  Get.find<SocketService>().connect(serverUrl);
  Get.put(ChatController());
  Get.put(custom.SearchController());
  String UserId = "";
  Get.put(EditEquipementController());
  Get.put(EquipmentController(UserId));
  Get.put(TechnicianController());
  Get.put(TicketController());
  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  final storage = Get.find<sessionController>();
  String? accessToken = await storage.readToken();
  String? storedId = await storage.readId();
  String? role = await storage.readRole();
  runApp(MyApp(isLoggedIn: accessToken != null, Id: storedId, role: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? Id;
  final String? role;
  const MyApp({super.key, required this.isLoggedIn, this.Id, this.role});

  String getInitialRoute() {
    if (isLoggedIn) {
      if (role == 'admin') {
        return AppRoutes.dashboard;
      } else if (role == 'technician') {
        return AppRoutes.technicianDashboard;
      } else if (role == 'client') {
        return AppRoutes.clientDashboard;
      }
    }
    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: getInitialRoute(),
      //initialRoute: AppRoutes.login,

      getPages: AppRoutes.routes,
    );
  }
}
