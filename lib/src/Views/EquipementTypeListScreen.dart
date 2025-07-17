import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/Widget/equipmentTypeProblems.dart';
import 'package:helpdesk/src/Views/editTypeEquip.dart';
import 'package:helpdesk/src/helpers/utils.dart';
import '../controllers/EquipmentTypeController.dart';
import '../helpers/consts.dart';

class EquipmentTypeListScreen extends StatelessWidget {
  final EquipmentTypeController controller = Get.put(EquipmentTypeController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
       key: _scaffoldKey,
      
      drawer: MenuWidget(currentIndex: 4),
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
                          "Types d'équipements",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap:  controller.navigateToAddForm,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Rechercher un type d\'équipement...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFF4A6FE5)),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4A6FE5), width: 1),
                                ),
                              ),
                              onChanged: (value) {
                                controller.searchEquipmentTypes(value);
                              },
                            ),
                          ),

                          // Equipment list
                          Expanded(
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return Container(); // Conteneur vide
                              }

                              final types = controller.filteredEquipmentTypes;

                              if (types.isEmpty &&
                                  !controller.isLoading.value) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.devices_other,
                                          size: 80,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Aucun type d'équipement trouvé",
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  itemCount: types.length,
                                  itemBuilder: (context, index) {
                                    final type = types[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 1,
                                      child: ListTile(
                                        onTap: () => Get.to(() =>
                                            EquipmentTypeProblems(
                                                idType: type.id)),
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: type.logo != null
                                              ? Image.network(
                                                  '$serverUrl/uploads/${type.logo!.fileName}',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                      Icons.devices_other,
                                                      size: 24,
                                                      color: Color(0xFF4A6FE5)),
                                                ),
                                        ),
                                        title: Text(
                                          type.typeName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 0, 1, 5),
                                          ),
                                        ),
                                        subtitle: Text(
                                          type.typeEquip,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey.shade600),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.teal
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: InkWell(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return EditEquipmentTypeForm(
                                                        typeEquipment: type);
                                                  },
                                                ),
                                                child: const Icon(Icons.edit,
                                                    size: 17,
                                                    color: Colors.teal),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: InkWell(
                                                onTap: () => controller
                                                    .confirmDeleteEquipment(
                                                        context, type.id),
                                                child: const Icon(Icons.delete,
                                                    size: 17,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
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
