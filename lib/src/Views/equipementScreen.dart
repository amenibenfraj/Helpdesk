import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/AddEquipForm.dart';
import 'package:helpdesk/src/helpers/utils.dart';

import '../controllers/equipement_controller.dart';
import '../helpers/consts.dart';
import 'Widget/EditequipDialog.dart';

class EquipmentListScreen extends StatelessWidget {
  final EquipmentController controller = Get.find<EquipmentController>();
  final TextEditingController searchController = TextEditingController();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
       key: _scaffoldKey,
      drawer: MenuWidget(currentIndex: 5),
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
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                        const Text(
                          "Équipements",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.dialog(AddEquipmentForm()).then((_) {
                              controller.fetchEquipments();
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
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Rechercher un équipement...',
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A6FE5)),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Color(0xFF4A6FE5), width: 1),
                                ),
                              ),
                              onChanged: (value) {
                                controller.searchEquipments(value);
                              },
                            ),
                          ),
                          
                          // Equipment list
                          Expanded(
                            child: Obx(() {
                              final equipments = controller.filteredEquipments;
                              if (equipments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.devices, size: 80, color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Aucun équipement trouvé",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: equipments.length,
                                  itemBuilder: (context, index) {
                                    final equip = equipments[index];
                                    return Dismissible(
                                      key: Key(equip.id ?? index.toString()),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                      confirmDismiss: (direction) async {
                                        if (equip.id != null) {
                                          controller.confirmDeleteEquipment(context, equip.id!);
                                        }
                                        return false;
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 1,
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: equip.typeEquipment?.logo != null
                                                ? Image.network(
                                                    '$serverUrl/uploads/${equip.typeEquipment!.logo!.fileName}',
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(Icons.devices, size: 24, color: Color(0xFF4A6FE5)),
                                                  ),
                                          ),
                                          title: Text(
                                            equip.designation,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(255, 0, 1, 5),
                                            ),
                                          ),
                                          subtitle: Text(
                                            equip.serialNumber,
                                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                          ),
                                         trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: () {
          Get.dialog(EditEquipementDialog(equipement: equip)).then((_) {
            controller.fetchEquipments(); // Recharge les équipements après l'édition
          });
        },
        child: const Icon(Icons.edit, size: 16, color: Colors.teal),
      ),
    ),
    const SizedBox(width: 8),
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: () {
           controller.confirmDeleteEquipment(context, equip.id!);
                 },
        child: const Icon(Icons.delete, size: 17, color: Colors.red),
      ),
    ),
  ],
),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
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
}