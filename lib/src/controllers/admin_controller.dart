import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:image_picker/image_picker.dart';

import '../models/Admin.dart';
import '../service/adminService.dart';

class AdminController extends GetxController {
  var admin = Rxn<Admin>();
  var isUpdated = false.obs;
//File? selectedFile;
 var selectedImage = Rxn<File>();
 final storage=Get.find<sessionController>();

  var isEditing = false.obs;

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
   final confpasswordController = TextEditingController();
      final newpasswordController = TextEditingController();


  void loadAdminData() {
    if (admin.value != null) {
      emailController.text = admin.value!.email ;
      firstNameController.text = admin.value!.firstname ;
      lastNameController.text = admin.value!.lastname ;
      phoneController.text = admin.value!.phoneNumber ?? '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    getProfileAdmin();
  }

  void fetchAdminData() async {
          

    try {
      final adminData = await Adminservice.getAdmin();
      if (adminData != null) {
        admin.value = adminData;
        print("Admin mis à jour : ${admin.value}");
      } else {
        print("aucun donnée recuperer");
      }
    } catch (e) {
      print("Erreur lors du chargement des données de l'admin: $e");
    }
  }

  Future<void> getProfileAdmin() async {
    try {
      String? idAdmin = await storage.readId();

      if (idAdmin == null) {
        return;
      }

      admin.value = await Adminservice.getAdmin();
      if (admin.value != null) {
        loadAdminData();
      } else {
        print("**********impossible de charger le profile");
      }
    } catch (e) {
      print("Erreur*******: $e");
      print("Erreur lors du chargement du profil: $e");
    }
  }

 Future<bool> updateAdmin(String email, String firstName, String lastName,
      String phoneNumber, File? image) async {
    isUpdated.value = false;

    try {
      String? id = await storage.readId();

      if (id == null) {
        print("ID Admin non trouvé");
        Get.snackbar("Erreur", "ID Admin non trouvé",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }

      bool success = await Adminservice.updateAdmin(
          id, email, firstName, lastName, phoneNumber, image);

      if (success) {
        isUpdated.value = true;
        await getProfileAdmin(); // Rafraîchir les données
        update();
        loadAdminData(); // Charger les données mises à jour dans les champs
       
        return true;
      } else {
        Get.snackbar("Échec", "La mise à jour a échoué",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            colorText: Colors.white);
        print("La mise à jour a échoué");
        return false;
      }
    } catch (e) {
      Get.snackbar("Erreur", "Erreur lors de la mise à jour : $e",
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Erreur lors de la mise à jour: $e");
      return false;
    }
  }



 Future<void> pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    selectedImage.value = File(pickedFile.path);
    update(); // Met à jour l'UI
  }
}
}
