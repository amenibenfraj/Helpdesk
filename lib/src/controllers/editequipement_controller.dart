import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/models/Equipement.dart';
import 'package:helpdesk/src/models/TypeEquipment.dart';
import 'package:helpdesk/src/service/EquipementsService.dart';
import 'package:helpdesk/src/service/TpeEquipementService.dart';

class EditEquipementController extends GetxController {
  var equipement = Rxn<Equipement>(); // Rxn permet d'avoir un état nul initial car on a des champs obligatoire on ne peut pas faire Equipement().obs

  var typesEquipement = <TypeEquipment>[].obs;
  var isLoading = false.obs;
  var selectedType = Rxn<String>(); // Rxn type dans getx => variable réactive qui peut être null
  
@override
void onInit() {
  super.onInit();
  loadTypesEquipement(); // Charger les types d'équipement au démarrage
}
  // Charge les types  depuis le service
 Future<List<TypeEquipment>> loadTypesEquipement() async {
  isLoading.value = true;
  try {
    // Récupère les types d'équipement depuis le service
    List<TypeEquipment> types = await TypeEquipementservice.getAllTypes();
    typesEquipement.assignAll(types); // Assigne la liste à la variable reactive
    return types; // Retourne la liste des types
  } catch (e) {
    Get.snackbar("Erreur", "Impossible de charger les types d'équipement : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    return []; 
  } finally {
    isLoading.value = false;
  }
}


  // Met à jour l'équipement avec les nouvelles valeurs
 Future<void> editEquipement(String id, Equipement equipement) async {
  try {
    TypeEquipment? newTypeEquipment;

    for (var type in typesEquipement) {
      if (type.id == selectedType.value) {
        newTypeEquipment = type;
        break;
      }
    }

    equipement.typeEquipment = newTypeEquipment;

    // Vérifier si l'équipement existe avant d'envoyer la requête
    await Equipementsservice.editEquipement(id, equipement);    

    Get.back();  
    
  } catch (e) {
    // Afficher un message d'erreur
    Get.snackbar(
      "Erreur",
      "Échec de la modification de l'équipement : $e",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
     // Retourne false si une erreur se produit
  }
}
}
