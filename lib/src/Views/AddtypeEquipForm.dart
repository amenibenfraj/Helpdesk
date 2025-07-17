import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/EquipmentTypeController.dart';

class AddEquipmentTypeForm extends StatefulWidget {
  const AddEquipmentTypeForm({super.key});

  @override
  _AddEquipmentTypeFormState createState() => _AddEquipmentTypeFormState();
}

class _AddEquipmentTypeFormState extends State<AddEquipmentTypeForm> {
  final EquipmentTypeController controller =
      Get.find<EquipmentTypeController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController typeNameController = TextEditingController();
  final TextEditingController typeEquipController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Réinitialiser le fichier sélectionné
    controller.selectedFile = null;
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
        title: Text(
          'Ajouter Type d\'Équipement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF6F8FF2),
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
                          return Column(
                            children: [
                              controller.selectedFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        controller.selectedFile!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Color(0xFF6F8FF2),
                                    ),
                              SizedBox(height: 8),
                              Text(
                                controller.selectedFile != null
                                    ? 'Image sélectionnée'
                                    : 'Ajouter une image',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              )
                            ],
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
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 67, 149, 226)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 67, 149, 226),
                                  width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Ce champ est obligatoire'
                              : null,
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
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 199, 199, 199)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 228, 228, 228),
                                  width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.3)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Ce champ est obligatoire'
                              : null,
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

                          controller.addTypeEquipment(typeNameController.text,
                              typeEquipController.text);

                          setState(() {
                            isLoading = false;
                          });
                          controller.fetchEquipmentTypes();
                          Get.back();
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
                          ? CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  'Ajouter',
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
