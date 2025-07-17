import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/equipement_controller.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/helpers/consts.dart';

class AssignEquipmentDialog extends StatelessWidget {
  final User user;
  final EquipmentController controller = Get.find<EquipmentController>();

  AssignEquipmentDialog({super.key, required this.user});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    controller.fetchEquipments();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 240, 240),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final unassigned = controller.equipmentList
                    .where((e) => e.assigned == false)
                    .toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Assigner un équipement',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (unassigned.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("Aucun équipement non assigné disponible."),
                      )
                    else
                      Expanded(
                        child: Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 6,
                          radius: const Radius.circular(10),
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: unassigned.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final equipment = unassigned[index];
                              
                              return Obx(() {
                                // Observer pour la sélection - cela permet une mise à jour immédiate lorsque sélectionné
                                final isSelected = controller.selectedEquipment.value == equipment;
                                
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectedEquipment.value = equipment;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.teal.shade50 : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.teal.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: isSelected ? Colors.teal.withOpacity(0.1) : Colors.grey.shade100,
                                          backgroundImage: equipment.typeEquipment?.logo?.fileName != null
                                              ? NetworkImage('$serverUrl/uploads/${equipment.typeEquipment!.logo!.fileName}')
                                              : null,
                                          child: equipment.typeEquipment?.logo?.fileName == null
                                              ? Icon(
                                                  Icons.devices_other, 
                                                  size: 28,
                                                  color: isSelected ? Colors.teal : Colors.grey.shade600,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            equipment.designation,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected ? Colors.teal.shade700 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.teal,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                          onPressed: () => Get.back(),
                          child: const Text('Annuler'),
                        ),
                        const SizedBox(width: 10),
                        Obx(() {
                          final isSelected = controller.selectedEquipment.value != null;
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.teal : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('Assigner'),
                            onPressed: isSelected
                                ? () {
                                    controller.assignEquipment(user.id, user.authority);
                                    Get.back();
                                  }
                                : null,
                          );
                        }),
                      ],
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}