import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/Admin.dart';
import 'package:helpdesk/src/models/User.dart';
import '../../controllers/notification_controller.dart';
import '../../service/AuthService.dart';
import '../NotificationScreen.dart';
import 'package:badges/badges.dart' as badges;

class NavbarScreen extends StatefulWidget {
  @override
  _NavbarScreenState createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  final sessionController session = Get.find<sessionController>();
    final NotificationController notifController = Get.put(NotificationController());
  
  User? user;
  Admin? admin;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final accessToken = await session.readToken();
      final userId = await session.readId();
      final userRole = await session.readRole();

      if (accessToken == null || userId == null || userRole == null) return;

      final url = userRole == 'admin'
          ? "$serverUrl/admin/getAdminById/$userId"
          : "$serverUrl/user/getUserById/$userId";

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userRole == 'admin'
              ? admin = Admin.fromJson(data)
              : user = User.fromJson(data);
        });
      }
    } catch (e) {
      print("Erreur NavbarScreen: $e");
    }
  }

  void _showUserOptions() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 30, right: 20),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: Colors.blue),
                      title: Text('Profile'),
                      onTap: () async {
                        Get.back();
                        final role = await session.readRole();
                        Get.toNamed(role == "admin" ? '/profile' : '/profileUser');
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout'),
                      onTap: () {
                        Authservice.logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
 Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 1, 132, 240),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.language, color: Colors.white),
                  onPressed: () {}, // futur multi-langue
                ),
                Obx(() {
                  int unreadCount = notifController.unreadCount.value;
                  return badges.Badge(
                    showBadge: unreadCount > 0,
                    badgeContent: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.all(6),
                    ),
                    position: badges.BadgePosition.topEnd(top: -4, end: -4),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () => Get.to(() => NotificationsScreen()),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showUserOptions,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: user != null
                          ? NetworkImage("$serverUrl/uploads/${user!.image!.fileName}")
                          : admin != null
                              ? NetworkImage("$serverUrl/uploads/${admin!.image!.fileName}")
                              : const AssetImage("assets/images/adminPic.jpeg") as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  }
