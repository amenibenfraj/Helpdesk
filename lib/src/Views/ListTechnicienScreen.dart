import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/Widget/AssignEquipementDialog.dart';
import 'package:helpdesk/src/Views/Widget/TechnicienDetailsDialog.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/controllers/technician_controller.dart';
import 'package:helpdesk/src/models/technician.dart';

import '../helpers/utils.dart';


class TechnicianListScreen extends StatelessWidget {
 
  final TechnicianController controller = Get.put(TechnicianController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TechnicianListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
       key: _scaffoldKey,
      drawer: const MenuWidget(currentIndex: 3),
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
            // Décorations en arrière-plan
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
                  // Barre d'app
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      
                      mainAxisAlignment: MainAxisAlignment.start,
                      
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
                            SizedBox(width: 15,),
                        const Center(
                        child: Text(
                          "Liste des techniciens",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                  // Barre de recherche
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher technicien...',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          controller.searchTechnichian(value);
                        },
                      ),
                    ),
                  ),
                  // Liste
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
                      child: _buildTechList(),
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

  Widget _buildTechList() {
    return Obx(() {
      // Si les données sont vides et en cours de chargement, montrer uniquement la liste vide
      if (controller.isLoading.value && controller.filteredTechnicians.isEmpty) {
        return Container(); // Ne rien afficher pendant le chargement initial
      } else if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      } else if (controller.filteredTechnicians.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_rounded,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "Aucun utilisateur trouvé",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await controller.fetchTechnicians(),
        color: const Color(0xFF4A6FE5),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: controller.filteredTechnicians.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            Technician user = controller.filteredTechnicians[index];
            return _buildUserCard(context, user, index);
          },
        ),
      );
    });
  }

  Widget _buildUserCard(BuildContext context, Technician user, int index) {
    return Dismissible(
      key: Key(user.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outlined, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF4A6FE5).withOpacity(0.1),
            backgroundImage: user.image?.fileName != null
                ? NetworkImage("$serverUrl/uploads/${user.image?.fileName}")
                : null,
            child: user.image?.fileName == null
                ? Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: const TextStyle(
                      color: Color(0xFF4A6FE5),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    user.phoneNumber ?? 'N/A',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    user.location ?? 'N/A',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => controller.confirmStatusChange(context, user),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (user.valid ?? false)
                        ? const Color(0xFF00C48C).withOpacity(0.1)
                        : const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    user.valid ?? false ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      color: (user.valid ?? false)
                          ? const Color(0xFF00C48C)
                          : const Color(0xFFFF6B6B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 20, color: Color(0xFF4A6FE5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'Technicien Details') {
                    _showTechnicianDetailsDialog(context, user);
                  } else if (value == 'Assign Equipment') {
                    _showAssignEquipmentDialog(context, user);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'Technicien Details',
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline,
                            size: 18, color: Color(0xFF4A6FE5)),
                        SizedBox(width: 8),
                        Text('Détails'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Assign Equipment',
                    child: Row(
                      children: const [
                        Icon(Icons.computer,
                            size: 18, color: Color(0xFF4A6FE5)),
                        SizedBox(width: 8),
                        Text('Attribuer équipement'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            _showTechnicianDetailsDialog(context, user);
          },
        ),
      ),
    );
  }

  void _showTechnicianDetailsDialog(
      BuildContext context, Technician technician) {
    showDialog(
      context: context,
      builder: (_) => TechnicianDetailsPage(user: technician),
    );
  }

  void _showAssignEquipmentDialog(BuildContext context, Technician user) {
    showDialog(
      context: context,
      builder: (context) => AssignEquipmentDialog(user: user),
    );
  }
}