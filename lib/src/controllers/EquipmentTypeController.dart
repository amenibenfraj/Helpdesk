import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helpdesk/src/models/TypeEquipment.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../Views/AddtypeEquipForm.dart';
import '../helpers/consts.dart';
import 'editequipement_controller.dart';

class EquipmentTypeController extends GetxController {
  File? selectedFile;
  EditEquipementController cntrl = Get.find<EditEquipementController>();
  var filteredEquipmentTypes = <TypeEquipment>[].obs;
  var equipmentTypes = <TypeEquipment>[].obs;
  var isLoading = true.obs;
  get showAddForm => null;

  @override
  void onInit() {
    fetchEquipmentTypes();
    super.onInit();
  }

  Future<void> fetchEquipmentTypes() async {
    isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/typeEquipment/getAllTypeEquipment'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TypeEquipment> types = (jsonData['rows'] as List)
            .map((e) => TypeEquipment.fromJson(e))
            .toList();
        equipmentTypes.assignAll(types);
        filteredEquipmentTypes.assignAll(equipmentTypes);
      } else {
        Get.snackbar('Error', 'Failed to fetch equipment types');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }finally {
      isLoading.value = false; // Indiquer que le chargement est terminé
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    print("Image selected: ${pickedFile?.path}");
    if (pickedFile != null) {
      selectedFile = File(pickedFile.path);
      update(); //maj UI
    }
  }
/***************************************************************/

  Future<void> addTypeEquipment(String typeName, var typeEquip) async {
    if (selectedFile == null) {
      Get.snackbar("Erreur", "Veuillez sélectionner une image");
      return;
    }

    // Vérifier le type MIME du fichier
    String? mimeType = lookupMimeType(selectedFile!.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      Get.snackbar(
          "Erreur", "Le fichier sélectionné n'est pas une image valide.");
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/typeEquipment/createTypeEquipment'),
      );
      request.fields['typeName'] = typeName;
      request.fields['typeEquip'] = typeEquip;
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        selectedFile!.path,
        contentType: MediaType.parse(mimeType),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Type équipement créé avec succès');
        cntrl.loadTypesEquipement();
      } else {
        Get.snackbar('Échec', 'Échec de l\'opération');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur s\'est produite : $e');
    }
  }

//search type equipement
  void searchEquipmentTypes(String query) {
    if (query.isEmpty) {
      filteredEquipmentTypes.assignAll(equipmentTypes);
    } else {
      filteredEquipmentTypes.assignAll(equipmentTypes.where(
          (type) => type.typeName.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void showEditForm(TypeEquipment type) {
    Get.toNamed('/editEquipmentType', arguments: type);
  }

  void navigateToDetails(TypeEquipment type) {
    Get.toNamed('/typeEquipmentDetails', arguments: type);
  }

  void navigateToAddForm() {
    Get.to(() => AddEquipmentTypeForm());
  }


 //delete type equipement
  Future<void> deleteTypeEquipment(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/typeEquipment/deleteTypeEquipment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': id}),
      );
      if (response.statusCode == 200) {
        equipmentTypes.removeWhere((element) => element.id == id);
        fetchEquipmentTypes(); //rafraichir la liste des types
        
      } else {
        Get.snackbar('Error', 'Failed to delete TypeEquipment',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

 void confirmDeleteEquipment(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(
          child: Text(
            'Êtes-vous sûr(e) ?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: const Text(
          "Voulez-vous vraiment supprimer ce type d'équipement ?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
              deleteTypeEquipment(id); // Appelle la fonction de suppression
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
//update type equipement
Future<void> updateTypeEquipment(String id, String typeName, String typeEquip) async {
  try {
    // Si un nouveau fichier est sélectionné, utilisez-le pour la mise à jour
    if (selectedFile != null) {
      // Vérifier le type MIME du fichier
      String? mimeType = lookupMimeType(selectedFile!.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        Get.snackbar("Erreur", "Le fichier sélectionné n'est pas une image valide.");
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$serverUrl/typeEquipment/updateTypeEquipment'),
      );
      request.fields['_id'] = id;
      request.fields['typeName'] = typeName;
      request.fields['typeEquip'] = typeEquip;
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        selectedFile!.path,
        contentType: MediaType.parse(mimeType),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Type équipement mis à jour avec succès');
        fetchEquipmentTypes();
      } else {
        Get.snackbar('Échec', 'Échec de la mise à jour');
      }
    } else {
      // Mise à jour sans image
      final response = await http.put(
        Uri.parse('$serverUrl/typeEquipment/updateTypeEquipment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          '_id': id,
          'typeName': typeName,
          'typeEquip': typeEquip
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Succès', 'Type équipement mis à jour avec succès');
        fetchEquipmentTypes();
      } else {
        Get.snackbar('Échec', 'Échec de la mise à jour');
      }
    }
  } catch (e) {
    Get.snackbar('Erreur', 'Une erreur s\'est produite : $e');
  }
}
}
