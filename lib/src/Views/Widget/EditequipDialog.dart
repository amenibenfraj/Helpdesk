import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/editequipement_controller.dart';
import '../../helpers/consts.dart';
import '../../models/Equipement.dart';
import '../../models/TypeEquipment.dart';


class EditEquipementDialog extends StatelessWidget {
  final Equipement equipement;
  final _formKey = GlobalKey<FormState>();

  EditEquipementDialog({Key? key, required this.equipement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditEquipementController());

    // Initialisation des valeurs
    controller.equipement.value = equipement;
    controller.selectedType.value = equipement.typeEquipment?.id ?? '';

    final TextEditingController designationController =
        TextEditingController(text: equipement.designation);
    final TextEditingController serialNumberController =
        TextEditingController(text: equipement.serialNumber);
    final TextEditingController barcodeController =
        TextEditingController(text: equipement.barcode ?? '');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Center(
  child: const Text(
    'Edit Equipement',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type d'équipement (Dropdown avec images et scroll horizontal)
              FutureBuilder<List<TypeEquipment>>(
                future: controller.loadTypesEquipement(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Erreur lors du chargement des types');
                  }

                  List<TypeEquipment> typesEquipement = snapshot.data ?? [];
                  return DropdownButtonFormField2<String>(
                    value: controller.selectedType.value!.isEmpty
                        ? null
                        : controller.selectedType.value,
                    onChanged: (newValue) {
                      controller.selectedType.value = newValue!;
                    },
                    isExpanded: true,
                    decoration:  InputDecoration(
                      labelText: "Type d'équipement",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 224, 217, 217),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Aucun type sélectionné'),
                      ),
                      for (var type in typesEquipement)
                        DropdownMenuItem<String>(
                          value: type.id,
                          child: Row(
                            children: [
                              // Affichage de l'image de type d'équipement
                               CircleAvatar(
                        radius: 30,
                        backgroundImage: type.logo?.fileName != null
                            ? NetworkImage(
                                '$serverUrl/uploads/${type.logo!.fileName}')
                            : null,
                        child: type.logo?.fileName == null
                            ? const Icon(Icons.devices_other, size: 30)
                            : null,
                      ),
                              const SizedBox(width: 10),
                              Flexible(
      child: Text(
        type.typeName,
        overflow: TextOverflow.ellipsis,
      ),
    ),
                            ],
                          ),
                        ),
                    ],
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300, // Limite la hauteur pour permettre un défilement
                      padding: EdgeInsets.zero,
                      scrollbarTheme: ScrollbarThemeData(
                        radius: Radius.circular(8),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Sélectionnez un type' : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Champs Text
              _buildTextField(
                'Désignation',
                designationController,
                'Veuillez entrer une désignation',
              ),
              _buildTextField(
                'Numéro de série',
                serialNumberController,
                'Veuillez entrer un numéro de série',
              ),
              _buildTextField(
                'Code-barres',
                barcodeController,
                'Veuillez entrer un code-barres',
              ),

              const SizedBox(height: 16),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Color.fromARGB(255, 170, 49, 41)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (controller.equipement.value != null) {
                          await controller.editEquipement(
                            controller.equipement.value!.id ?? '',
                            controller.equipement.value!,
                          );
                          
                        } else {
                          Get.snackbar("Erreur", "Aucun équipement sélectionné",
                              margin: const EdgeInsets.all(10),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 19, 87, 143),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                   child: const Text(
  "Edit",
  style: TextStyle(
    color: Color.fromARGB(255, 150, 186, 216),
  ),
),

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour créer les champs de texte
  Widget _buildTextField(String label, TextEditingController controller, String validatorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor:  Color.fromARGB(255, 224, 217, 217),
        ),
        validator: (value) => value!.isEmpty ? validatorMessage : null,
      ),
    );
  }
}
