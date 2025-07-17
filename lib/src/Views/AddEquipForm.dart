import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/equipement_controller.dart';
import '../helpers/consts.dart';
import '../models/Equipement.dart';
import '../models/TypeEquipment.dart';
import '../service/TpeEquipementService.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddEquipmentForm extends StatefulWidget {
  AddEquipmentForm({Key? key}) : super(key: key);

  @override
  _AddEquipmentFormState createState() => _AddEquipmentFormState();
}

class _AddEquipmentFormState extends State<AddEquipmentForm> {
  final EquipmentController controller = Get.find<EquipmentController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serialNumberController;
  late TextEditingController _designationController;
  late TextEditingController _versionController;
  late TextEditingController _barcodeController;
  late TextEditingController _referenceController;
  
  String? _selectedTypeId; // Utilisation de l'ID au lieu de l'objet complet
  List<TypeEquipment> _typesList = []; 

  @override
  void initState() {
    super.initState();
    _serialNumberController = TextEditingController();
    _designationController = TextEditingController();
    _versionController = TextEditingController();
    _barcodeController = TextEditingController();
    _referenceController = TextEditingController();
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _designationController.dispose();
    _versionController.dispose();
    _barcodeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Center(
        child: Text(
          'Ajouter un Équipement',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Numéro de série", _serialNumberController),
              _buildTextField("Désignation", _designationController),
              _buildTextField("Version", _versionController),
              _buildTextField("Code-barres", _barcodeController),
              _buildTextField("Référence", _referenceController),
              
              FutureBuilder<List<TypeEquipment>>(
                future: TypeEquipementservice.getAllTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text("Erreur de chargement des types ");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucun type d'équipement disponible");
                  }
                  
                  
                  _typesList = snapshot.data!;
                  
                 
                  return DropdownButton2<String>(
                    hint: const Text('Sélectionner le type d\'équipement'),
                    value: _selectedTypeId,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTypeId = newValue;
                      });
                    },
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                      direction: DropdownDirection.left, 
                    ),
                    items: _typesList.map((TypeEquipment type) {
                      return DropdownMenuItem<String>(
                        value: type.id, 
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                         
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: type.logo?.fileName != null
                                    ? NetworkImage('$serverUrl/uploads/${type.logo!.fileName}')
                                    : null,
                                backgroundColor: Colors.grey.shade200,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  type.typeName,
                                  style: TextStyle(
                                    fontWeight: _selectedTypeId == type.id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                   
                                  ),
                                ),
                              ),
                              if (_selectedTypeId == type.id)
                                const Icon(Icons.check, color: Colors.blue, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    actions: [
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              iconColor: Color.fromARGB(255, 170, 49, 41),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text(
              'Close',
              style: TextStyle(
                color: Color.fromARGB(255, 170, 49, 41),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _addEquipment(); 
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 19, 87, 143),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  ),
],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color.fromARGB(255, 224, 217, 217),
        ),
        validator: (value) => value!.isEmpty ? "Ce champ est requis" : null,
      ),
    );
  }

  Future<void> _addEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    // Trouver l'objet TypeEquipment correspondant à l'ID sélectionné
    TypeEquipment? selectedType;
    if (_selectedTypeId != null) {
      try {
        selectedType = _typesList.firstWhere(
          (type) => type.id == _selectedTypeId,
        );
      } catch (e) {
        // Si aucun type correspondant n'est trouvé
        print("Type non trouvé pour l'ID: $_selectedTypeId");
      }
    }

    Equipement newEquipment = Equipement(
      id: '',
      serialNumber: _serialNumberController.text,
      designation: _designationController.text,
      version: _versionController.text,
      barcode: _barcodeController.text,
      reference: _referenceController.text,
      typeEquipment: selectedType,
    );
    controller.createEquipment(newEquipment);
  }
}