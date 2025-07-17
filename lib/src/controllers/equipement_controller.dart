import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/editequipement_controller.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/Equipement.dart';
import 'package:helpdesk/src/service/EquipementsService.dart';
import 'package:helpdesk/src/service/UserService.dart';
import 'package:http/http.dart';

import '../models/TypeEquipment.dart';

class EquipmentController extends GetxController {
  var equipmentList = <Equipement>[].obs;
  var selectedEquipment = Rxn<Equipement>();
  var filteredEquipments = <Equipement>[].obs;
  var isLoading = false.obs;
  final String userId;
  final EditEquipementController editEquipementController =
      Get.find<EditEquipementController>();
  EquipmentController(this.userId);

  Rx<String> serialNumber = ''.obs;
  Rx<String> designation = ''.obs;
  Rx<String> version = ''.obs;
  Rx<String> barcode = ''.obs;
  Rx<bool> assigned = false.obs;
  Rx<String> reference = ''.obs;
  Rx<TypeEquipment?> typeEquipment = Rx<TypeEquipment?>(null);

//get equipemntByuser
  void fetchEquipmentByUser(String userId) async {
    isLoading.value = true;
    try {
      var equipments = await Userservice.fetchEquipements(userId);

      if (equipments != null) {
        equipmentList.assignAll(equipments);
      }
    } catch (e) {
      print('***********  $e');

      
    } finally {
      isLoading.value = false;
    }
  }

  //alleqyupement
  void fetchEquipments() async {
    try {
      var equipments = await Equipementsservice.getListEquipment();
      //print('***********  $equipments');
      if (equipments != null) {
        equipmentList.assignAll(equipments);
        filteredEquipments.assignAll(equipments);
      }
    } catch (e) {
      print('***********  $e');

     
    } finally {
      isLoading.value = false;
    }
  }

//assigné d'un equipement
  Future<void> assignEquipment(String userId, String role) async {
    if (selectedEquipment.value == null) {
      Get.snackbar(
          "Erreur", "Veuillez sélectionner un équipement avant d'assigner",
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
          colorText: Colors.white);
      return;
    }
    try {
      bool success = await Equipementsservice.assignEquipmentUser(
        equipmentId: selectedEquipment.value!.id ?? '',
        userId: userId,
        role: role,
      );

      if (success) {
        fetchEquipmentByUser(userId);
       
      } else {}
    } catch (e) {
      print(e);
    }
  }

  //delete equipmentUser
  Future<void> deleteEquipment(
      String equipmentId, String userId, String role) async {
    try {
      bool success = await Equipementsservice.deleteEquipementUser(
          equipmentId, userId, role);
      if (success) {
        // Rafraîchir la liste des équipements après suppression
        fetchEquipmentByUser(userId);
      } else {
        Get.snackbar("Echec", "Échec de la suppression de l'équipement",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print(e);
    }
  }

  // Appel de la fonction editEquipment du EditEquipementController
  Future<void> editSelectedEquipment() async {
    if (selectedEquipment.value != null) {
      await editEquipementController.editEquipement(
        selectedEquipment.value!.id ?? '',
        selectedEquipment.value!,
      );
      fetchEquipmentByUser(userId);
    }
  }

  //fonction de sélection d'équipement
  void selectEquipment(Equipement equipment) {
    selectedEquipment.value = equipment;
  }

//serach equipement
  void searchEquipments(String query) {
    if (query.isEmpty) {
      filteredEquipments.assignAll(equipmentList);
    } else {
      filteredEquipments.assignAll(equipmentList.where((type) =>
          type.designation.toLowerCase().contains(query.toLowerCase())));
    }
  }

//supprimer un equipement
  Future<void> deleteEquip(String id) async {
    try {
      final response = await delete(
        Uri.parse('$serverUrl/equipmentHelpdesk/deleteEquipmentHelpdesk/$id'),
      );
      if (response.statusCode == 200) {
        equipmentList.removeWhere((element) => element.id == id);
        fetchEquipments(); //rafraichir la liste des types
       
      } 
    } catch (e) {
     print(e);
    }
  }

  Future<void> createEquipment(Equipement newEquipment) async {
    bool success = await Equipementsservice.createEquipment(newEquipment);

    if (success) {
     

      fetchEquipments();
    } 
  }

 void confirmDeleteEquipment(BuildContext context, String equipmentId) {
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
          "Voulez-vous vraiment supprimer cet équipement ?",
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
              Navigator.of(context).pop(); 
              deleteEquip(equipmentId);  
                 
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

  @override
  void onInit() {
    super.onInit();
    fetchEquipments();
  }
}
