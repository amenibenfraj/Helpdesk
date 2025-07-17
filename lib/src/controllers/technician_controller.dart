import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/models/technician.dart';
import 'package:helpdesk/src/service/TechService.dart';
import 'package:image_picker/image_picker.dart';

import '../models/FileModel.dart';
import '../service/AuthService.dart';

class TechnicianController extends GetxController {
  var technicians = <Technician>[].obs; // Liste des techniciens observable
  var technician = Rxn<Technician>();
  var filteredTechnicians = <Technician>[].obs;
  var isLoading = true.obs; // Indicateur de chargement des données
  var errorMessage = ''.obs; // Message d'erreur en cas de problème
File? selectedFile;
 Rxn<FileModel> selectedImage = Rxn<FileModel>();
//signup form
   final formKey = GlobalKey<FormState>();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var roleController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var serviceController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  String? selectedRole = 'technician'; 

  @override
  void onInit() {
    super.onInit();
    fetchTechnicians();
  }


  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); // "pickedFile" contenant les infos du fichier sélectionné
    if (pickedFile != null) {
      String fileName = pickedFile.name;
      String filePath = pickedFile.path;

      // Créer un objet FileModel
      selectedImage.value = FileModel(
        title: 'Profile Picture', 
        fileName: fileName, 
        path: filePath, 
      );
      update(); // Mettre à jour l'UI
    }
  }
// Fonction pour soumettre le formulaire signup
   void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar('Échec', 'Les mots de passe ne correspondent pas');
        return;
      }

      if (selectedImage.value == null) {
      Get.snackbar('Échec', 'Veuillez ajouter une photo');
      //print("***aucune image sélectionnee ");
      return;
    }

    // print("image sélectionnee : ${selectedImage.value?.path}");
    

      Technician tech = Technician(
        id: '',
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        authority: selectedRole!,
        email: emailController.text,
        password: passwordController.text,
        phoneNumber: phoneNumberController.text,
        service: serviceController.text,
        image: selectedImage.value,
      );

      Authservice.register(tech).then((statusCode) {
        if (statusCode == 201) {
          Get.snackbar('Succès', 'Inscription réussie');

          Get.toNamed('/login');
        } else {
          Get.snackbar('Erreur', 'Échec de l\'inscription. Code: $statusCode');
        }
      }).catchError((error) {
        Get.snackbar('Erreur', 'Erreur de connexion: $error');
      });
    }
  }


  // Récupère les techniciens
  Future<void> fetchTechnicians() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Réinitialiser le message d'erreur
      List<Technician>? fetchedTechnicians = await Techservice.getTechnicians();
      if (fetchedTechnicians != null) {
        technicians.assignAll(fetchedTechnicians); // Remplacer la liste des techniciens
        filteredTechnicians.assignAll(fetchedTechnicians); // Initialiser la liste filtrée
      } else {
        errorMessage.value = 'Aucun technicien trouvé';
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des techniciens : $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer la liste des techniciens en fonction de la requête saisie dans la barre de recherche
  void filterTechnicians(String query) {
    if (query.isEmpty) {
      filteredTechnicians.assignAll(technicians); // Réinitialiser à la liste complète
    } else {
      filteredTechnicians.assignAll(technicians.where((tech) {
        return tech.email.toLowerCase().contains(query.toLowerCase()) ||
            tech.phoneNumber!.toLowerCase().contains(query.toLowerCase()) ||
            tech.firstName.toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }

   void searchTechnichian(String query) {
    if (query.isEmpty) {
      filteredTechnicians.assignAll(technicians);
    } else {
      filteredTechnicians.assignAll(
          technicians.where((type) => type.firstName.toLowerCase().contains(query.toLowerCase()))
      );
    }
  }
  
Future<void> updateTechnicianStatus(String id, bool valid) async {
  try {
    isLoading(true);
  
    final updated = await Techservice.updateStatTech(id, valid);
    
    if (updated) {
      // Recharger la liste maj des techniciens
      await fetchTechnicians();

      Get.snackbar(
        'Succès',
        valid ? 'Compte  activé' : 'Compte  désactivé',

   
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut du technicien',
        backgroundColor: Colors.red,


      );
    }
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Une erreur est survenue: $e',
      backgroundColor: Colors.red,


    );
  } finally {
    isLoading(false);
  }
}

void confirmStatusChange(BuildContext context, Technician technician) {
  final bool newStatus = !technician.valid!;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              newStatus ? Icons.check_circle_outline : Icons.highlight_off,
              size: 48,
              color: newStatus ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              newStatus ? 'Activer le compte' : 'Désactiver le compte',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Voulez-vous vraiment ${newStatus ? 'activer' : 'désactiver'} '
              'le compte de ${technician.firstName} ${technician.lastName} ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    updateTechnicianStatus(technician.id, newStatus);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newStatus ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

}
