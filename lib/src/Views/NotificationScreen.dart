import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/models/Solution.dart';
import 'package:helpdesk/src/models/Ticket.dart';
import 'package:helpdesk/src/service/TicketService.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import 'TicketDetails.dart';

// ignore: must_be_immutable
class NotificationsScreen extends StatelessWidget {
  final NotificationController controller = Get.find<NotificationController>();
  final sessionController session = Get.find<sessionController>();
  late Solution solution;

  NotificationsScreen({super.key});

  String timeAgo(String? dateStr) {
    if (dateStr == null) return "";
    final date = DateTime.tryParse(dateStr);
    if (date == null) return "";
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "à l'instant";
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    if (diff.inDays < 7) return "il y a ${diff.inDays} j";
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A6FE5),
              Color(0xFF6F8FF2),
              Color(0xFFB6C5F8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              left: -30,
              top: 70,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 150,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.markAllAsRead();
                            controller.updateUnreadCount();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.done_all_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Obx(() {
                        return RefreshIndicator(
                          onRefresh: controller.refreshNotifications,
                          color: const Color(0xFF4A6FE5),
                          child: controller.notifications.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15),
                                    Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.notifications_off_rounded,
                                              size: 80,
                                              color: Colors.grey.shade300),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Aucune notification reçue",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .slideY(begin: 0.2, end: 0),
                                  ],
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  itemCount: controller.notifications.length,
                                  separatorBuilder: (_, __) => const SizedBox(
                                      height:
                                          8), // Réduit l'espace entre les cartes
                                  itemBuilder: (context, index) {
                                    final notif =
                                        controller.notifications[index];
                                    final createdAt = notif.createdAt ?? '';
                                    final isRead = notif.read;

                                    // Animating each notification item
                                    return Dismissible(
                                      key: Key(notif.id.toString()),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B6B),
                                          borderRadius: BorderRadius.circular(
                                              12), // Réduit la courbure pour un look plus compact
                                        ),
                                        child: const Icon(Icons.delete_outlined,
                                            color: Colors.white),
                                      ),
                                      onDismissed: (_) async {
                                        final notifToDelete = notif;
                                        controller.notifications
                                            .removeAt(index);
                                        final success =
                                            await controller.deleteNotification(
                                                notifToDelete.id);

                                        if (!success) {
                                          controller.notifications
                                              .insert(index, notifToDelete);
                                          Get.snackbar(
                                            "Erreur",
                                            "Échec de suppression",
                                            backgroundColor:
                                                const Color(0xFFFF6B6B),
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(12),
                                            borderRadius: 10,
                                            duration:
                                                const Duration(seconds: 2),
                                            snackPosition: SnackPosition.BOTTOM,
                                            icon: const Icon(
                                                Icons.error_outline,
                                                color: Colors.white),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isRead
                                              ? Colors.white
                                              : const Color(0xFFF5F7FF),
                                          borderRadius: BorderRadius.circular(
                                              12), // Réduit la courbure pour un look plus compact
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.03), // Ombre plus légère
                                              blurRadius:
                                                  5, // Réduction du flou
                                              offset: const Offset(
                                                  0, 3), // Décalage plus petit
                                            ),
                                          ],
                                          border: isRead
                                              ? Border.all(
                                                  color: Colors.grey.shade200)
                                              : Border.all(
                                                  color: const Color(0xFF4A6FE5)
                                                      .withOpacity(0.3)),
                                        ),
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal:
                                                  12, // Réduit le padding horizontal
                                              vertical:
                                                  8, // Réduit le padding vertical
                                            ),
                                            leading: Container(
                                              padding: const EdgeInsets.all(
                                                  6), // Réduit la taille du conteneur
                                              decoration: BoxDecoration(
                                                color: isRead
                                                    ? Colors.grey.shade100
                                                    : const Color(0xFF4A6FE5)
                                                        .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isRead
                                                    ? Icons.notifications_none
                                                    : Icons
                                                        .notifications_active,
                                                color: isRead
                                                    ? Colors.grey.shade600
                                                    : const Color(0xFF4A6FE5),
                                                size:
                                                    20, // Réduit la taille de l'icône
                                              ),
                                            ),
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom:
                                                      4.0), // Réduit l'espace
                                              child: Text(
                                                notif.message,
                                                style: TextStyle(
                                                  fontWeight: isRead
                                                      ? FontWeight.normal
                                                      : FontWeight.w600,
                                                  fontSize:
                                                      14, // Réduit la taille du texte
                                                  color: isRead
                                                      ? Colors.grey.shade800
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            subtitle: Text(
                                              timeAgo(createdAt),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize:
                                                    12, // Réduit la taille du texte
                                              ),
                                            ),
                                            trailing: isRead
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .all(
                                                        3), // Réduit le padding
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF00C48C)
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Color(0xFF00C48C),
                                                      size:
                                                          16, // Réduit la taille de l'icône
                                                    ),
                                                  )
                                                : Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical:
                                                            4), // Réduit le padding
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF4A6FE5)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Réduit la courbure
                                                    ),
                                                    child: const Text(
                                                      "Nouveau",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF4A6FE5),
                                                        fontSize:
                                                            10, // Réduit la taille du texte
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                            onTap: () async {
                                              Ticket t = await Ticketservice
                                                  .getTicketById(
                                                      notif.ticketId);
                                              String? role =
                                                  await session.readRole();

                                              print(
                                                  "Ticket Status: ${t.status}");
                                              print("User Role: $role");

                                              if (role == 'client' ||
                                                  role == 'admin'||
                                                  role == 'technician' ) {
                                                if (notif.type =="new-ticket" || notif.type == "taken-ticket" || notif.type == "assign-ticket" ) {
                                                  if (context.mounted) {
                                                    showTicketDetailsDialog(
                                                        context, t);
                                                  }
                                                } else {
                                                  if (context.mounted ) {
                                                    print(
                                                        "TICKET SOLUTION : ${t.solution}");
                                                    print(
                                                        "TICKET SOLUTION CONTENT : ${t.solution?.solution}");
                                                    Get.toNamed('/chat',
                                                        arguments: t.id);
                                                  }
                                                }
                                              }
                                            }),
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(
                                            duration: 300.ms,
                                            delay: (index * 50).ms)
                                        .slideY(
                                            begin: 0.05,
                                            end: 0); // Animation plus subtile
                                  },
                                ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void showTicketDetailsDialog(BuildContext context, Ticket t) {
    showDialog(
      context: context,
      builder: (context) => Ticketdetails(ticket: t),
      barrierDismissible: false,
    );
  }
}
