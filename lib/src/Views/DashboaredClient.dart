import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/NotificationScreen.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/helpers/utils.dart';
import '../controllers/notification_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/Ticket.dart';

class DashboardController extends GetxController {
  final TicketController ticketController = Get.find<TicketController>();
  
  int allTickets = 0;
  int inProgressTickets = 0;
  int resolvedTickets = 0;
  int closedTickets = 0;
  
  @override
  void onInit() {
    super.onInit();
    loadStats();
    
    
  }
  
  Future<void> loadStats() async {
    await ticketController.loadTicketsByUserHelpdesk();
    
    allTickets = ticketController.TicketUser.length;
    inProgressTickets = ticketController.TicketUser
        .where((t) => t.status == "In Progress")
        .length;
    resolvedTickets = ticketController.TicketUser
        .where((t) => t.status == "Resolved")
        .length;
    closedTickets = ticketController.TicketUser
        .where((t) => t.status == "Closed")
        .length;
    
    update(); // Mettre à jour l'interface
  }
}

class DashboaredClient extends StatefulWidget {
  const DashboaredClient({super.key});

  @override
  State createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<DashboaredClient> {
  final storage = Get.find<sessionController>();
  final NotificationController notifController =
      Get.put(NotificationController());
  final sessionController session = Get.find<sessionController>();
  
  // Initialiser le controller de dashboard
  final dashboardController = Get.put(DashboardController());
  final TicketController ticketController = Get.find<TicketController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuUser(Index: 0),
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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  final NotificationController controller =
                                      Get.find<NotificationController>();
                                  controller.updateUnreadCount();
                                  Get.to(() => NotificationsScreen());
                                },
                              ),
                              // Notification badge
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Obx(() {
                                  final NotificationController controller =
                                      Get.find<NotificationController>();
                                  controller.updateUnreadCount();

                                  return controller.unreadCount.value > 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 14,
                                            minHeight: 14,
                                          ),
                                          child: Text(
                                            controller.unreadCount.value > 99
                                                ? '99+'
                                                : '${controller.unreadCount.value}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                }),
                              ),
                            ],
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: GetBuilder<DashboardController>(
                          builder: (controller) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Cards
                                _buildStatsCards(controller)
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 100.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 24),

                                // Ticket Status Overview
                                _buildTicketStatusOverview(controller)
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 400.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 24),

                                // Recent Tickets
                                _buildRecentTickets()
                                    .animate()
                                    .fadeIn(delay: 500.ms, duration: 400.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 80),
                              ],
                            );
                          },
                        ),
                      ),
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

  Widget _buildStatsCards(DashboardController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: "Total Tickets",
          value: controller.allTickets.toString(),
          icon: Icons.confirmation_number_outlined,
          color: const Color(0xFF4A6FE5),
        ),
        _buildStatCard(
          title: "In Progress",
          value: controller.inProgressTickets.toString(),
          icon: Icons.timer,
          color: const Color(0xFFFFA113),
        ),
        _buildStatCard(
          title: "Resolved",
          value: controller.resolvedTickets.toString(),
          icon: Icons.check_circle_outline,
          color: const Color(0xFF00C48C),
        ),
        _buildStatCard(
          title: "Closed",
          value: controller.closedTickets.toString(),
          icon: Icons.archive_outlined,
          color: const Color.fromARGB(255, 93, 94, 94),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStatusOverview(DashboardController controller) {
    final int total = controller.allTickets > 0 ? controller.allTickets : 1;
    final double inProgressPercentage = controller.inProgressTickets / total * 100;
    final double resolvedPercentage = controller.resolvedTickets / total * 100;
    final double closedPercentage = controller.closedTickets / total * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ticket Status Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6FE5),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 180,
                    width: 150,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 60,
                            sections: [
                              PieChartSectionData(
                                value: inProgressPercentage,
                                color: const Color(0xFFFFA113),
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: resolvedPercentage,
                                color: const Color(0xFF00C48C),
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: closedPercentage,
                                color: const Color.fromARGB(255, 93, 94, 94),
                                radius: 20,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.allTickets.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6FE5),
                                ),
                              ),
                              const Text(
                                "Total",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          title: "In Progress",
                          percentage:
                              "${inProgressPercentage.toStringAsFixed(1)}%",
                          color: const Color(0xFFFFA113),
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          title: "Resolved",
                          percentage:
                              "${resolvedPercentage.toStringAsFixed(1)}%",
                          color: const Color(0xFF00C48C),
                        ),
                        _buildLegendItem(
                          title: "Closed",
                          percentage: "${closedPercentage.toStringAsFixed(1)}%",
                          color: const Color.fromARGB(255, 93, 94, 94),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String title,
    required String percentage,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 12,
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    percentage,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTickets() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Tickets",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6FE5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/ticketUser');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FE5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF4A6FE5),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFF4A6FE5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (ticketController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ticketController.TicketUser.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No tickets created yet. Create your first ticket!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Show 3 most recent tickets
            return FutureBuilder<List<Ticket>>(
              future: ticketController.getRecentTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Aucun ticket récent');
                } else {
                  final recentTickets = snapshot.data!;

                  return Column(
                    children: recentTickets
                        .map((ticket) => Column(
                              children: [
                                _buildTicketItem(
                                  title: ticket.title,
                                  number: ticket.number,
                                  priority: ticket.niveauEscalade ?? "Medium",
                                  status: ticket.status,
                                  date: formatDate(ticket.creationDate),
                                ),
                                if (ticket != recentTickets.last)
                                  const Divider(),
                              ],
                            ))
                        .toList(),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}";
  }

  Widget _buildTicketItem({
    required String title,
    required String number,
    required String priority,
    required String status,
    required String date,
  }) {
    Color priorityColor;
    switch (priority) {
      case "High":
        priorityColor = const Color(0xFFFF6B6B);
        break;
      case "Medium":
        priorityColor = const Color(0xFFFFA113);
        break;
      default:
        priorityColor = const Color(0xFF00C48C);
    }

    Color statusColor;
    switch (status) {
      case "Open":
        statusColor = const Color(0xFFFFA113);
        break;
      case "In Progress":
        statusColor = const Color(0xFF4A6FE5);
        break;
      case "Resolved":
        statusColor = const Color(0xFF00C48C);
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed('/ticketDetails', arguments: number);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4A6FE5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF4A6FE5),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "#$number - $date",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
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