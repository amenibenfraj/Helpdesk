import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../controllers/ticket_controller.dart';
import '../../helpers/consts.dart';
import '../../models/technician.dart';
import '../../service/TicketService.dart';

class AssignTicketDialog extends StatefulWidget {
  final List<Technician> technicians;
  final String ticketId;

  const AssignTicketDialog({
    super.key,
    required this.technicians,
    required this.ticketId,
  });

  @override
  State<AssignTicketDialog> createState() => _AssignTicketDialogState();
}

class _AssignTicketDialogState extends State<AssignTicketDialog> {
  final TicketController ticketController = Get.find<TicketController>();
  final List<String> selectedIds = [];



  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Assign Technicians',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: const Text(
                  'Sélectionner les techniciens',
                  style: TextStyle(fontSize: 16),
                ),
                items: widget.technicians.map((tech) {
                  final id = tech.id;
                  final name = "${tech.firstName} ${tech.lastName}";
                  final imageUrl =
                      "$serverUrl/uploads/${tech.image?.fileName}";

                  return DropdownMenuItem<String>(
                    value: id,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        final isSelected = selectedIds.contains(id);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? selectedIds.remove(id)
                                  : selectedIds.add(id);
                            });
                            menuSetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(imageUrl),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check,
                                      color: Colors.blue, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade100,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: (_) {},
              ),
            ),

            const SizedBox(height: 20),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Veuillez sélectionner au moins un technicien"),
                        ),
                      );
                      return;
                    }

                    final success = await Ticketservice.assignTechnicianToTicket(
                      widget.ticketId,
                      selectedIds,
                    );

                    if (success) {
                      await ticketController.fetchTickets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Techniciens affectés avec succès !")),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Échec de l'affectation des techniciens")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Affecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
