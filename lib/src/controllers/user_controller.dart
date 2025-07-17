import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/service/UserService.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/consts.dart';
import '../models/Ticket.dart';

class UserController extends GetxController {
  var users = <User>[].obs; // Liste des users observable
  var user = Rxn<User>();
  var isUpdated = false.obs;
  var filteredUsers = <User>[].obs;
  var selectedImage = Rxn<File>();
  var isLoading = true.obs; // Indicateur de chargement des données
  var errorMessage = ''.obs; // Message d'erreur en cas de problème
  var userId = ''.obs;
    var TicketUser = <Ticket>[].obs;
  final storage = FlutterSecureStorage();

  var isEditing = false.obs;

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var newpasswordController = TextEditingController();
  var confpasswordController = TextEditingController();
  var locationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initialUser();
  }

  Future<void> initialUser() async {
    await loadUserId();
    await fetchUsers();
    await fetchUserData();
  }

  void loadUserData() async {
    if (user.value != null) {
      emailController.text = user.value!.email;
      firstNameController.text = user.value!.firstName;
      lastNameController.text = user.value!.lastName;
      phoneController.text = user.value!.phoneNumber ?? '';
      locationController.text = user.value!.location ?? '';
    }
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await Userservice.getUser();
      if (userData != null) {
        user.value = userData;
        //print("user mis à jour : ${user.value}");
      } else {
        print("aucun donnée recuperer");
      }
    } catch (e) {
      print("Erreur lors du chargement des données de user: $e");
    }
  }

  Future<void> getProfileUser() async {
   // print("//////////////////////////////// fetch profile data from profile");

    try {
      String? idUser = await storage.read(key: USER_ID);

      if (idUser == null) {
        return;
      }

      user.value = await Userservice.getUser();
      if (user.value != null) {
        loadUserData();
      } else {
        print("**********impossible de charger le profile");
      }
    } catch (e) {
      print("Erreur*******: $e");
      print("Erreur lors du chargement du profil: $e");
    }
  }

  Future<bool> updateUser(String? id ,String email, String firstName, String lastName,
      String phoneNumber, String location, File? image) async {
    isUpdated.value = false;

    try {
      String? id = await storage.read(key: USER_ID);

      if (id == null) {
        print("ID User non trouvé");
        Get.snackbar("Erreur", "ID User non trouvé",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }

      bool success = await Userservice.updateUser(
          id, email, firstName, lastName, phoneNumber, location, image);

      if (success) {
        isUpdated.value = true;
        await getProfileUser(); // Rafraîchir les données
        update();
        loadUserData(); // Charger les données mises à jour dans les champs
        Get.snackbar("Succès", "User modifié avec succès",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.teal,
            colorText: Colors.white);
        return true;
      } else {
        Get.snackbar("Échec", "La mise à jour a échoué",
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            colorText: Colors.white);
        print("La mise à jour a échoué");
        return false;
      }
    } catch (e) {
      Get.snackbar("Erreur", "Erreur lors de la mise à jour : $e",
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Erreur lors de la mise à jour: $e");
      return false;
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      update(); // Met à jour l'UI
    }
  }

  // Fonction pour charger l'ID de l'utilisateur à partir du stockage sécurisé
  Future<void> loadUserId() async {
    String? storedId = await storage.read(key: USER_ID);
    if (storedId != null) {
      userId.value = storedId; // Assigner l'ID récupéré à la variable réactive
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Réinitialiser le message d'erreur
      List<User>? fetchedUsers = await Userservice.getAllUsers();
      if (fetchedUsers != null) {
        users.assignAll(fetchedUsers); // Remplacer la liste des techniciens
        filteredUsers.assignAll(fetchedUsers); // Initialiser la liste filtrée
      } else {
        errorMessage.value = 'Aucun user trouvé';
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des users : $e';
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      filteredUsers.assignAll(users); // Réinitialiser à la liste complète
    } else {
      filteredUsers.assignAll(users.where((user) {
        return user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.phoneNumber!.toLowerCase().contains(query.toLowerCase()) ||
            user.firstName.toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }

  void editUser(String id, User newUser) async {
    try {
      // MAJ de user dans la liste
      for (var i = 0; i < users.length; i++) {
        if (users[i].id == id) {
          users[i] = newUser;
          update(); // MAJ de l'état avec GetX
          break;
        }
      }

      //await Userservice.editUser(id, newUser);

      // Rafraîchir la liste
      fetchUsers();

      Get.snackbar(
        "Succès",
        "Utilisateur modifié avec succès",
        backgroundColor: Colors.teal,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        "Erreur",
        "Modification échouée : $error",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

//change password

  var pwdController = TextEditingController();
  var newpwdController = TextEditingController();
  var confpwdController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> changePassword() async {
    String currentPassword = pwdController.text;
    String newPassword = newpwdController.text;
    String confirmPassword = confpwdController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar("Erreur", "Tous les champs sont obligatoires",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    bool success =
        await Userservice.changePassword(currentPassword, newPassword);
    if (success) {
      Get.snackbar("Succès", "Mot de passe changé avec succès",
           colorText: Colors.black);
      clearFields();
    } else {
      Get.snackbar("Erreur", "Échec du changement de mot de passe",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void clearFields() {
  pwdController.clear();
  newpwdController.clear();
  confpwdController.clear();
}

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      filteredUsers.assignAll(users.where((type) =>
          type.firstName.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void setUser(User newUser) {
    user.value = newUser;
    //loadTicketsByUserHelpdesk();
  }
  //  Future<void> loadTicketsByUserHelpdesk() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //     TicketUser.clear();  // Réinitialiser les tickets
  //     if (user.value != null) {
  //       var tickets = await Ticketservice.getTicketByUserHelpdesk(); // Appel API avec l'ID de l'utilisateur
  //       TicketUser.assignAll(tickets ?? []);  // Affecter les tickets récupérés
  //       if (tickets == null || tickets.isEmpty) {
  //         errorMessage.value = "Aucun ticket trouvé pour ce technicien";
  //       } else {
  //         errorMessage.value = '';
  //       }
  //     } else {
  //       errorMessage.value = "Utilisateur non valide";
  //     }
  //   } catch (e) {
  //     print("Erreur : $e");
  //     errorMessage.value = "Erreur lors du chargement des tickets";
  //     TicketUser.clear();
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void logout() {
    user.value = null; // Réinitialisation des données utilisateur
  }

 void confirmStatusChange(BuildContext context, User user) {
  final bool newStatus = !user.valid!;

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
              'le compte de ${user.firstName} ${user.lastName} ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Annuler'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    updateUserStatus(user.id, newStatus);
                  },
                  
                  label: const Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: newStatus ? Colors.green : Colors.red, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Future<void> updateUserStatus(String id, bool valid) async {
    try {
      isLoading(true);

      final updated = await Userservice.updateStatUser(id, valid);

      if (updated) {
        
        await fetchUsers();

        Get.snackbar(
          'Succès',
          valid ? 'Compte  activé' : 'Compte  désactivé',
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de modifier le statut du user',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading(false);
    }
  }


}
