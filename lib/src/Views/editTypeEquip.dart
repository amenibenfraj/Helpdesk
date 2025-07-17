import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/EquipmentTypeController.dart';
import '../helpers/consts.dart';
import '../models/TypeEquipment.dart';

class EditEquipmentTypeForm extends StatefulWidget {
  final TypeEquipment? typeEquipment;
  const EditEquipmentTypeForm({super.key, this.typeEquipment});

  @override
  _EditEquipmentTypeFormState createState() => _EditEquipmentTypeFormState();
}

class _EditEquipmentTypeFormState extends State<EditEquipmentTypeForm> {
  final EquipmentTypeController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController typeNameController;
  late TextEditingController typeEquipController;
  TypeEquipment? typeEquipmentToEdit;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    typeEquipmentToEdit = widget.typeEquipment;
    

    typeNameController = TextEditingController(text: typeEquipmentToEdit?.typeName ?? '');
    typeEquipController = TextEditingController(text: typeEquipmentToEdit?.typeEquip ?? '');

    typeNameController = TextEditingController();
    typeEquipController = TextEditingController();

    controller.selectedFile = null;

    if (typeEquipmentToEdit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
            'Erreur',
            'Aucun type d\'équipement à modifier',
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      });
    }
  }

  @override
  void dispose() {
    typeNameController.dispose();
    typeEquipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Type d\'Équipement', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        backgroundColor: Colors.blue.shade900.withOpacity(0.7),
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 203, 217, 231),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                 Center(
  child: GestureDetector(
    onTap: () => controller.pickImage(),
    child: GetBuilder<EquipmentTypeController>(
      builder: (controller) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: controller.selectedFile != null
              ? Image.file(
                  controller.selectedFile!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : (typeEquipmentToEdit?.logo != null
                  ? Image.network(
                      '$serverUrl/uploads/${typeEquipmentToEdit!.logo?.fileName}',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 67, 149, 226),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Erreur de chargement', style: TextStyle(color: Colors.grey)),
                          ],
                        );
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 50,
                          color: Color.fromARGB(255, 67, 149, 226),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ajouter une image',
                          style: TextStyle(
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
        );
      },
    ),
  ),
),

                  // Form Fields
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom du type',
                           
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 55, 56, 56),
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.05),),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.05), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                          ),
                          validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
                          controller: typeNameController,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Type (Hard/Soft)',
                            
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 55, 56, 56),
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.05),),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.05), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                          ),
                          validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
                          controller: typeEquipController,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            isLoading = true;
                          });

                          // Vérifier que l'ID est disponible avant la mise à jour
                          if (typeEquipmentToEdit?.id != null) {
                            controller.updateTypeEquipment(
                                typeEquipmentToEdit!.id,
                                typeNameController.text,
                                typeEquipController.text
                            );

                            Get.back();
                          } else {
                            Get.snackbar(
                                'Erreur',
                                'Impossible de mettre à jour : ID manquant',
                                backgroundColor: Colors.red,
                                colorText: Colors.white
                            );
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6F8FF2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  'Mettre à jour',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Pour l'appelant, vous pouvez continuer à utiliser:
// IconButton(
//   icon: const Icon(Icons.edit, size: 18, color: Colors.teal),
//   onPressed: () => Get.toNamed('/editEquipmentType', arguments: type),
//   tooltip: "Modifier",
// ),