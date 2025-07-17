import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/Views/Widget/EditequipDialog.dart';
import 'package:helpdesk/src/controllers/equipement_controller.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/Equipement.dart';
import 'package:helpdesk/src/service/EquipementsService.dart';

class Equipementlist extends StatelessWidget {
  final String UserId;
  final String role;

  Equipementlist({required this.UserId, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final EquipmentController equipmentController =
            Get.find<EquipmentController>();
        equipmentController.fetchEquipmentByUser(UserId);

        if (equipmentController.equipmentList.isEmpty) {
          return const Center(child: Text('Aucun équipement disponible'));
        }

        final equipements = equipmentController.equipmentList;

        return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: equipements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final e = equipements[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: e.typeEquipment?.logo?.fileName != null
                            ? NetworkImage(
                                '$serverUrl/uploads/${e.typeEquipment!.logo!.fileName}')
                            : null,
                        child: e.typeEquipment?.logo?.fileName == null
                            ? const Icon(Icons.devices_other, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.designation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number, size: 16, color: const Color.fromARGB(255, 99, 28, 28)),
                                const SizedBox(width: 4),
                                Text(
                                  'SN: ${e.serialNumber}',
                                  style: TextStyle(color: const Color.fromARGB(255, 99, 28, 28)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showEditEquipDialog(context, e);
                            },
                            child: const Icon(Icons.edit, color: Colors.teal, size: 22),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              _confirmDeleteEquipment(context, e.id!);
                            },
                            child: const Icon(Icons.delete, color: Colors.red, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

void _confirmDeleteEquipment(BuildContext context, String equipementId) {
 showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Supprimer l'équipement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Voulez-vous vraiment supprimer cet équipement ?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Utilisation de Expanded pour les boutons
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text("Annuler",style: TextStyle(fontSize: 12),),
                  ),
                ),
                const SizedBox(width: 12), // Espace entre les boutons
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await Equipementsservice.deleteEquipementUser(equipementId, UserId, role);
                      Get.back();
                      Get.snackbar(
                        "Succès",
                        "Équipement supprimé avec succès",
                        margin: const EdgeInsets.all(12),
                        colorText: Colors.black,
                      );
                    },
                    child: const Text("Supprimer",style: TextStyle(fontSize: 12),),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  },
);}
 void _showEditEquipDialog(BuildContext context, Equipement e) async {
    bool? updated = await showDialog(
      context: context,
      builder: (context) => EditEquipementDialog(equipement: e),
    );

    if (updated == true) {
      Get.find<EquipmentController>().fetchEquipments();
      Get.back();
    }
  }
}
