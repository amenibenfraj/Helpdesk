import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helpers/consts.dart';
import '../models/Notification.dart';

import 'sessionController.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  final sessionController session = Get.find<sessionController>();
  final RxInt unreadCount = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchNotifications(); // Charger les notifs au démarrage
  }

  Future<void> fetchNotifications() async {
    final userId = await session.readId();
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/notification/getUserNotifications/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("////////////$data");
        final List<dynamic> rows = data['rows'];
        notifications.value =
            rows.map((json) => NotificationModel.fromJson(json)).toList();
            updateUnreadCount();
      } else {
        print("Erreur de chargement des notifications : ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des notifications : $e");
    }
  }
  void updateUnreadCount() {
  unreadCount.value =
      notifications.where((notif) => notif.read == false).length;
}
  Future<void> markAllAsRead() async {
    final userId = await session.readId();
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/notification/markAllAsRead'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        await fetchNotifications(); // Recharger les notifs
      }
    } catch (e) {
      print('Erreur lors du marquage des notifications comme lues : $e');
    }
  }

  Future<void> markOneAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/notification/markOneAsRead'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notificationId': notificationId}),
      );
      if (response.statusCode == 200) {
        await fetchNotifications(); // Recharger les notifs
      }
    } catch (e) {
      print('Erreur lors du marquage de la notification comme lue : $e');
    }
  }

//supprimer notif
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await http
          .delete(Uri.parse("$serverUrl/notification/deleteNotification/$id"));
      if (response.statusCode == 200) {
        notifications.removeWhere((notif) => notif.id == id);
        Get.snackbar(' notification has deleted with Succes', '');
        return true;
      } else {
        Get.snackbar("echec", "echec de suppression cette notification!");
        return false;
      }
    } catch (error) {
      print("erreur:$error");
      return false;
    }
  }

  Future<void> refreshNotifications() async {
    // Ajoute ici ton appel à l’API si nécessaire
    await Future.delayed(Duration(seconds: 1)); // Simule le refresh
    fetchNotifications();
  }
}
