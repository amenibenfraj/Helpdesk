import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/TicketDetails.dart';
import 'package:helpdesk/src/controllers/ticket_controller.dart';
import 'package:helpdesk/src/helpers/utils.dart';
import 'package:helpdesk/src/models/Ticket.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../controllers/chat_controller.dart';
import 'Widget/userAddTicket.dart';

class ListticketbyUser extends StatefulWidget {
  @override
  _ListticketbyUserState createState() => _ListticketbyUserState();
}

class _ListticketbyUserState extends State<ListticketbyUser> {
  final TicketController controller = Get.find<TicketController>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Réinitialiser et charger les tickets immédiatement quand cette page est créée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceRefreshTickets();
    });
  }

  // Méthode pour forcer le rafraîchissement des tickets
  void _forceRefreshTickets() {
    // Effacer d'abord les anciens tickets
    controller.TicketUser.clear();
    // Réinitialiser les filtres
    //controller.searchQuery.value = '';
    controller.currentFilter.value = '';
    // Charger les nouveaux tickets
    controller.loadTicketsByUserHelpdesk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuUser(Index: 1),
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
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const Text(
                          "My Tickets",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                child: UserTicketForm(),
                              ),
                              barrierDismissible: false,
                            ).then((_) {
                              controller.loadTicketsByUserHelpdesk();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Search bar
                          _buildSearchBar(context),
                          const SizedBox(height: 16),
                          // Tickets List
                          Expanded(
                            child: ticketlist(),
                          ),
                        ],
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

 
Widget _buildSearchBar(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search tickets...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  controller.searchTicketsUser(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A6FE5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: 
           Obx(() {
  final filteredTickets = controller.TicketUser.where((ticket) {
    if (ticket.status == "Deleted") return false;
    
    final matchesSearch = ticket.number
            .toLowerCase()
            .contains(controller.searchQuery.value.toLowerCase()) ||
        ticket.title
            .toLowerCase()
            .contains(controller.searchQuery.value.toLowerCase());

    final matchesStatus = controller.currentFilter.value.isEmpty ||
        ticket.status == controller.currentFilter.value;

    return matchesSearch && matchesStatus;
  }).length;

  return Text(
    "$filteredTickets tickets",
    style: const TextStyle(
      color: Color(0xFF4A6FE5),
      fontWeight: FontWeight.w500,
    ),
  );
})
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Status filters
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildStatusChip(context, "All", Colors.grey),
          const SizedBox(width: 8),
          _buildStatusChip(
              context, "Assigned", const Color.fromARGB(255, 46, 136, 182)),
          const SizedBox(width: 8),
          _buildStatusChip(context, "Not Assigned", Colors.blueGrey),
          const SizedBox(width: 8),
          _buildStatusChip(context, "In Progress", Colors.orange),
          const SizedBox(width: 8),
          _buildStatusChip(context, "Resolved", Colors.green),
          const SizedBox(width: 8),
          _buildStatusChip(context, "Closed", Colors.black),
        ],
      ),
    ],
  );
}
  Widget _buildStatusChip(BuildContext context, String status, Color color) {
    return Obx(() {
      final isSelected = controller.currentFilter.value == status ||
          (status == "All" && controller.currentFilter.value.isEmpty);

      return GestureDetector(
        onTap: () {
          controller.filterTicketUserByStatus(status == "All" ? "" : status);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget ticketlist() {
    return Obx(() {
      // Vérification du chargement et de la liste vide
      if (controller.isLoading.value && controller.TicketUser.isEmpty) {
        return Container();
      } else if (controller.errorMessage.value.isNotEmpty) {
        // Affichage en cas d'erreur
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => controller.loadTicketsByUserHelpdesk(),
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A6FE5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Filtrage des tickets en fonction de la recherche, du statut et exclusion des tickets "Deleted"
      final filteredTickets = controller.TicketUser.where((ticket) {
        // Exclure les tickets avec status "Deleted"
        if (ticket.status == "Deleted") {
          return false;
        }
        
        final matchesSearch = ticket.title
                .toLowerCase()
                .contains(controller.searchQuery.value.toLowerCase()) ||
            ticket.description
                .toLowerCase()
                .contains(controller.searchQuery.value.toLowerCase());
        final matchesStatus = controller.currentFilter.value.isEmpty ||
            ticket.status == controller.currentFilter.value;
        return matchesSearch && matchesStatus;
      }).toList();

      // Affichage si aucun ticket n'est trouvé après filtrage
      if (filteredTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                "No tickets available",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Add a new ticket to get started",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      // Affichage de la liste de tickets avec un effet de rafraîchissement
      return RefreshIndicator(
        onRefresh: () async {
          await controller.loadTicketsByUserHelpdesk();
        },
        color: Color(0xFF4A6FE5),
        child: Scrollbar(
          controller: _scrollController,
          thickness: 6,
          radius: Radius.circular(10),
          thumbVisibility: true,
          interactive: true,
          child: AnimationLimiter(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8, bottom: 16),
              itemCount: filteredTickets.length,
              itemBuilder: (context, index) {
                final ticket = filteredTickets[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildTicketCard(context, ticket),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final statusColor = controller.getStatusColor(ticket.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTicketDetailsDialog(context, ticket),
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(ticket.status),
                            size: 18,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "N° ${ticket.number}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${ticket.creationDate.day}-${ticket.creationDate.month}-${ticket.creationDate.year}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Title: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: '${ticket.title}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                // Description
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'description: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: '${ticket.description}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                if (ticket.status != "Closed") ...[
                  SizedBox(height: 12),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  _buildActionButtons(context, ticket),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'In Progress':
        return Icons.timelapse;
      case 'Resolved':
        return Icons.check_circle_outline;
      case 'Closed':
        return Icons.done_all;
      case 'Deleted':
        return Icons.delete_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildActionButtons(BuildContext context, Ticket ticket) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Edit button
          if (ticket.status == "Assigned" || ticket.status == "Not Assigned")
            _buildActionButton(
              icon: Icons.edit,
              iconColor: Color(0xFF00C48C),
              label: "Edit",
              onPressed: () {
                Get.toNamed('/editTicket', arguments: ticket);
              },
            ),

          // Chat button
          if (ticket.status == "In Progress" || ticket.status == "Resolved")
            _buildActionButton(
              icon: Icons.chat,
              iconColor: Color(0xFF4A6FE5),
              label: "Chat",
              onPressed: () async {
                final chatController = Get.find<ChatController>();
                await ChatController.preloadMessages(ticket.id, chatController);
                Get.toNamed('/chat', arguments: ticket.id);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color iconColor,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTicketDetailsDialog(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => Ticketdetails(ticket: ticket),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}