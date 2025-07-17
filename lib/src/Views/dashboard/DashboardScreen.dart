import 'package:get/get.dart';
import 'package:helpdesk/src/service/TicketService.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/sessionController.dart';
import '../../controllers/ticket_controller.dart';
import '../../models/Ticket.dart';
import '../NotificationScreen.dart';
import '../../helpers/utils.dart';

class DashboardController extends GetxController {
  final TicketController ticketController = Get.find<TicketController>();

  // Use RxInt for reactive properties to match the pattern
  RxInt allTickets = 0.obs;
  RxInt notassignedTickets = 0.obs;
  RxInt inProgressTickets = 0.obs;
  RxInt assignedTickets = 0.obs;
  RxInt resolvedTickets = 0.obs;
  RxInt closedTickets = 0.obs;
  RxInt deletedTickets = 0.obs;

  // RxInt niveau1Tickets = 0.obs;
  // RxInt niveau2Tickets = 0.obs;
  // RxInt niveau3Tickets = 0.obs;
  
  // Reactive for technician tickets
  RxList<Map<String, dynamic>> technicianTickets = <Map<String, dynamic>>[].obs;
  RxInt maxResolvedTickets = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatsWithTechnicians();
  }
 
  Future<void> loadStatsWithTechnicians() async {
    await ticketController.fetchTickets();
    allTickets.value = ticketController.Tickets.length;
    notassignedTickets.value =
        ticketController.Tickets.where((t) => t.status == "Not Assigned").length;
    assignedTickets.value =
        ticketController.Tickets.where((t) => t.status == "Assigned").length;
    inProgressTickets.value =
        ticketController.Tickets.where((t) => t.status == "In Progress").length;
    resolvedTickets.value =
        ticketController.Tickets.where((t) => t.status == "Resolved").length;
    closedTickets.value =
        ticketController.Tickets.where((t) => t.status == "Closed").length;
    deletedTickets.value =
        ticketController.Tickets.where((t) => t.status == "Deleted").length;
    
    // Niveaux
    // niveau1Tickets.value = await Ticketservice.getLevel1TicketsCount();
    // niveau2Tickets.value = await Ticketservice.getLevel2TicketsCount();
    // niveau3Tickets.value = await Ticketservice.getLevel3TicketsCount();
    
    // Charger et calculer les statistiques par technicien
    await loadTicketsByTechnician();
    
    update(); // Update UI
  }

  // Helper method for chart max level
  // int getMaxTicketLevel() {
  //   return [niveau1Tickets.value, niveau2Tickets.value, niveau3Tickets.value]
  //           .reduce((a, b) => a > b ? a : b) +5;
  // }
  
  Future<void> loadTicketsByTechnician() async {
    try {
      // Récupérer tous les tickets
      List allTicketsData = ticketController.Tickets;
      
      if (allTicketsData.isEmpty) {
        // Si aucun ticket n'est disponible, essayez de les charger directement
        allTicketsData = await Ticketservice.getTotalTickets() ?? [];
      }
      
      // Créer un Map  pour stocker des stats par nom de technicien, avec les compteurs par statut
      Map<String, Map<String, int>> technicianStats = {};
      
      for (var ticket in allTicketsData) {
        // Vérifier si le ticket a des techniciens assignés
        if (ticket.technicienId != null && ticket.technicienId!.isNotEmpty) {
          for (var tech in ticket.technicienId!) {
            String techName = tech.firstName;
            
            // Initialiser les stats pour ce technicien s'il n'existe pas encore
            if (!technicianStats.containsKey(techName)) {
              technicianStats[techName] = {
                "total": 0,
                "resolved": 0,
                "in_progress": 0,
                "assigned": 0,
                "closed": 0
              };
            }
            
            // Incrémenter le total
            technicianStats[techName]!["total"] = (technicianStats[techName]!["total"] ?? 0) + 1;
            
            // Incrémenter selon le statut
            switch (ticket.status) {
              case "Resolved":
                technicianStats[techName]!["resolved"] = (technicianStats[techName]!["resolved"] ?? 0) + 1;
                break;
              case "In Progress":
                technicianStats[techName]!["in_progress"] = (technicianStats[techName]!["in_progress"] ?? 0) + 1;
                break;
              case "Assigned":
                technicianStats[techName]!["assigned"] = (technicianStats[techName]!["assigned"] ?? 0) + 1;
                break;
              case "Closed":
                technicianStats[techName]!["closed"] = (technicianStats[techName]!["closed"] ?? 0) + 1;
                break;
            }
          }
        } 
      }
      
      // Convertir Map<String, Map<String, int>> en  liste d’objets (Map), plus facile à afficher dans l'UI
      technicianTickets.value = technicianStats.entries
          .map((entry) => {
                "technicien": entry.key,
                "count": entry.value["total"] ?? 0,
                "resolved": entry.value["resolved"] ?? 0,
                "in_progress": entry.value["in_progress"] ?? 0,
                "assigned": entry.value["assigned"] ?? 0,
                "closed": entry.value["closed"] ?? 0,
              })
          .toList();
      
      // Calculer le maximum pour l'échelle du graphique (basé sur les tickets résolus)
      if (technicianTickets.isNotEmpty) {
        maxResolvedTickets.value = technicianTickets
            .map((item) => item["resolved"] as int)
            .reduce((a, b) => a > b ? a : b) + 5;
      }
    } catch (e) {
      print("Erreur lors du chargement des tickets par technicien: $e");
      // Initialiser avec une valeur par défaut pour éviter les erreurs
      technicianTickets.value = [
        {"technicien": "Aucune donnée", "count": 0, "resolved": 0, "in_progress": 0, "assigned": 0, "closed": 0}
      ];
      maxResolvedTickets.value = 5;
    }
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final sessionController storage;
  late final NotificationController notifController;
  late final sessionController session;
  late final DashboardController dashboardController;
  late final TicketController ticketController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    storage = Get.find<sessionController>();
    session = Get.find<sessionController>();
    notifController = Get.put(NotificationController());
    dashboardController = Get.put(DashboardController());
    ticketController = Get.find<TicketController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuWidget(currentIndex: 1),
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
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                const Text(
                                  "Admin Dashboard",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                                  notifController.updateUnreadCount();
                                  Get.to(() =>  NotificationsScreen());
                                },
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GetBuilder<NotificationController>(
                                  builder: (controller) {
                                    controller.updateUnreadCount();
                                    return controller.unreadCount > 0
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.white, width: 1),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 14,
                                              minHeight: 14,
                                            ),
                                            child: Text(
                                              controller.unreadCount > 99 ? '99+' : '${controller.unreadCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                _buildDonutChartCard(controller)
                                    .animate()
                                    .fadeIn(delay: 200.ms, duration: 400.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 24),
                                _buildTechnicianBarChartCard(controller)
                                    .animate()
                                    .fadeIn(delay: 400.ms, duration: 400.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 24),
                                _buildTicketHistory()
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 400.ms)
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
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }

 Widget _buildDonutChartCard(DashboardController controller) {
  //Calcule les pourcentages pour chaque statut de ticket 
  final int total = controller.allTickets.value > 0 ? controller.allTickets.value : 1;
  final double assignedPercentage = controller.assignedTickets.value / total * 100;
  final double notassignedPercentage = controller.notassignedTickets.value / total * 100;
  final double inProgressPercentage = controller.inProgressTickets.value / total * 100;
  final double resolvedPercentage = controller.resolvedTickets.value / total * 100;
  final double closedPercentage = controller.closedTickets.value / total * 100;
  final double deletedPercentage = controller.deletedTickets.value / total * 100;

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Diagramme circulaire
            Expanded(
              flex: 4,
              child: Container(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 55,
                        sections: [
                          PieChartSectionData(
                            value: notassignedPercentage,
                            color: const Color.fromARGB(255, 186, 186, 187),
                            radius: 25,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: assignedPercentage,
                            color: const Color.fromARGB(255, 19, 102, 255),
                            radius: 25,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: inProgressPercentage,
                            color: const Color(0xFFFFA113),
                            radius: 25,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: resolvedPercentage,
                            color: const Color(0xFF00C48C),
                            radius: 25,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: closedPercentage,
                            color: const Color.fromARGB(255, 93, 94, 94),
                            radius: 25,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: deletedPercentage,
                            color: const Color.fromARGB(255, 255, 30, 1),
                            radius: 25,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.allTickets.value.toString(),
                            style: const TextStyle(
                              fontSize: 22,
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
            ),
            
            // Partie droite: Légende et statistiques
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildLegendRow(
                    firstItem: _buildLegendItem(
                      title: "Not Assigned",
                      percentage: "${notassignedPercentage.toStringAsFixed(1)}%",
                      color: const Color.fromARGB(255, 186, 186, 187),
                      count: controller.notassignedTickets.value.toString(),
                    ),
                    secondItem: _buildLegendItem(
                      title: "Assigned",
                      percentage: "${assignedPercentage.toStringAsFixed(1)}%",
                      color: const Color.fromARGB(255, 19, 102, 255),
                      count: controller.assignedTickets.value.toString(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendRow(
                    firstItem: _buildLegendItem(
                      title: "In Progress",
                      percentage: "${inProgressPercentage.toStringAsFixed(1)}%",
                      color: const Color(0xFFFFA113),
                      count: controller.inProgressTickets.value.toString(),
                    ),
                    secondItem: _buildLegendItem(
                      title: "Resolved",
                      percentage: "${resolvedPercentage.toStringAsFixed(1)}%",
                      color: const Color(0xFF00C48C),
                      count: controller.resolvedTickets.value.toString(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendRow(
                    firstItem: _buildLegendItem(
                      title: "Closed",
                      percentage: "${closedPercentage.toStringAsFixed(1)}%",
                      color: const Color.fromARGB(255, 93, 94, 94),
                      count: controller.closedTickets.value.toString(),
                    ),
                    secondItem: _buildLegendItem(
                      title: "Deleted",
                      percentage: "${deletedPercentage.toStringAsFixed(1)}%",
                      color: const Color.fromARGB(255, 255, 30, 1),
                      count: controller.deletedTickets.value.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Méthodes helper inchangées
Widget _buildLegendRow({required Widget firstItem, required Widget secondItem}) {
  return Row(
    children: [
      Expanded(child: firstItem),
      const SizedBox(width: 10),
      Expanded(child: secondItem),
    ],
  );
}

Widget _buildLegendItem({
  required String title,
  required String percentage,
  required Color color,
  required String count,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: "$count ("),
                  TextSpan(
                    text: percentage,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const TextSpan(text: ")"),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}  
  Widget _buildTechnicianBarChartCard(DashboardController controller) {
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
          const Text(
            "Tickets Résolus par Technicien",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6FE5),
            ),
          ),
          const SizedBox(height: 20),
          _buildTechnicianBarChart(controller),
        ],
      ),
    );
  }

  Widget _buildTechnicianBarChart(DashboardController controller) {
    List<Color> techColors = [
      const Color(0xFF4A6FE5),
      
    ];

    return Obx(() {
      if (controller.technicianTickets.isEmpty) {
        return const Center(
          heightFactor: 5,
          child: Column(
            children: [
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Chargement des données...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFEEEEEE),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            if (index >= 0 && index < controller.technicianTickets.length) {
                              String techName = controller.technicianTickets[index]["technicien"] as String;
                              if (techName.length > 8) {
                                techName = "${techName.substring(0, 6)}..";
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  techName,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: List.generate(
                      controller.technicianTickets.length,
                      (index) {
                        int resolvedCount = controller.technicianTickets[index]["resolved"] as int;
                        return _animatedTechnicianBarGroup(
                          index,
                          resolvedCount.toDouble() * value,
                          techColors[index % techColors.length],
                          controller,
                        );
                      },
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: const Color(0xFF4A6FE5).withOpacity(0.8),
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex < controller.technicianTickets.length) {
                            String techName = controller.technicianTickets[groupIndex]["technicien"] as String;
                            int resolved = controller.technicianTickets[groupIndex]["resolved"] as int;
                            int inprogress = controller.technicianTickets[groupIndex]["in_progress"] as int;

                            int total = controller.technicianTickets[groupIndex]["count"] as int;
                            
                            return BarTooltipItem(
                              '$techName\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Résolus: $resolved\n',
                                  style: const TextStyle(
                                    color: Color(0xFF00C48C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  
                                ),
                                TextSpan(
                                  text: 'en cours: $inprogress\n',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 219, 128, 9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),),
                                TextSpan(
                                  text: 'Total tickets: $total',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
        ],
      );
    });
  }

  BarChartGroupData _animatedTechnicianBarGroup(
    int x, 
    double toY, 
    Color color, 
    DashboardController controller
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: toY,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: controller.maxResolvedTickets.value.toDouble(),
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketHistory() {
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
                "Ticket History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6FE5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/tickets');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FE5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
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
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(),
                )
              );
            }

            if (ticketController.Tickets.isEmpty) {
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

            return FutureBuilder<List<Ticket>>(
              future: ticketController.getLatestThreeTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Container(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No recent tickets');
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
    String minutes = date.minute < 10 ? '0${date.minute}' : '${date.minute}';
    return "${date.day}/${date.month}/${date.year}, ${date.hour}:$minutes";
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
      case "Not Assigned":
        statusColor= const Color.fromARGB(255, 186, 186, 187);
        break;
      case "In Progress":
        statusColor = const Color(0xFFFFA113);
        break;
      case "Assigned":
        statusColor = const Color(0xFF4A6FE5);
        break;
      case "Resolved":
        statusColor = const Color(0xFF00C48C);
        break;
      case "Closed":
        statusColor = const Color.fromARGB(255, 65, 66, 66);
        break;
      case "Deleted":
        statusColor = const Color.fromARGB(255, 196, 0, 0);
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