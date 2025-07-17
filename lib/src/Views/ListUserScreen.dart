import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helpdesk/src/Views/Widget/AssignEquipementDialog.dart';
import 'package:helpdesk/src/Views/Widget/TechnicienDetailsDialog.dart';
import 'package:helpdesk/src/controllers/technician_controller.dart';
import 'package:helpdesk/src/controllers/user_controller.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/service/UserService.dart';

import '../helpers/utils.dart';

class UserListScreen extends StatelessWidget {
  final UserController controller = Get.find<UserController>();
  final TechnicianController techController = Get.find<TechnicianController>();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldKey,
      drawer: const MenuWidget(currentIndex: 33),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A6FE5),
              Color(0xFF6F8FF2),
              Color(0xFFB6C5F8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              left: -30,
              top: 70,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 150,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          const Center(
                        child: Text(
                          "Liste des utilisateurs",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),SizedBox(width: 40,),
                        GestureDetector(
                          onTap: () {
                            _showDialogAddUser(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher utilisateur...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          controller.searchUser(value);
                        },
                      ),
                    ),
                  ),
                  // Main Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _buildUserList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildUserList() {
    return Obx(() {
      // Si les données sont vides et en cours de chargement, montrer uniquement la liste vide
      
      if (controller.isLoading.value && controller.filteredUsers.isEmpty) {
        return Container(); // Ne rien afficher pendant le chargement initial
      } else if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      } else if (controller.filteredUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "Aucun utilisateur trouvé",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => await controller.fetchUsers(),
        color: const Color(0xFF4A6FE5),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: controller.filteredUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            User user = controller.filteredUsers[index];
            return _buildUserCard(context, user, index);
          },
        ),
      );
    });
  }

Widget _buildUserCard(BuildContext context, User user, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF4A6FE5).withOpacity(0.1),
          backgroundImage: user.image?.fileName != null 
              ? NetworkImage("$serverUrl/uploads/${user.image?.fileName}")
              : null,
          child: user.image?.fileName == null
              ? Text(
                  '${user.firstName[0]}${user.lastName[0]}',
                  style: const TextStyle(
                    color: Color(0xFF4A6FE5),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user.phoneNumber ?? 'N/A',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  user.location ?? 'N/A',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.confirmStatusChange(context, user),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (user.valid ?? false)
                      ? const Color(0xFF00C48C).withOpacity(0.1)
                      : const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.valid ?? false ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: (user.valid ?? false)
                        ? const Color(0xFF00C48C)
                        : const Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF4A6FE5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'User Details') {
                  _showTechnicianDetailsDialog(context, user);
                } else if (value == 'Assign Equipment') {
                  _showAssignEquipmentDialog(context, user);
                } else if (value == 'Edit User') {
                  _showEditUserDialog(context, user);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'Edit User',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Color(0xFF4A6FE5)),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'User Details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Color(0xFF4A6FE5)),
                      SizedBox(width: 8),
                      Text('Détails'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Assign Equipment',
                  child: Row(
                    children: [
                      Icon(Icons.computer, size: 18, color: Color(0xFF4A6FE5)),
                      SizedBox(width: 8),
                      Text('Attribuer équipement'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianDetailsPage(user: user),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.05, end: 0);
  }
  void _showDialogAddUser(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    var firstnameController = TextEditingController();
    var lastnameController = TextEditingController();
    var emailController = TextEditingController();
    var phoneController = TextEditingController();
    var locationController = TextEditingController();
    var serviceController = TextEditingController();
    String authority = 'client';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FE5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Color(0xFF4A6FE5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ajouter un utilisateur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6FE5),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledTextField(
                    label: 'Prénom',
                    controller: firstnameController,
                    errorMessage: 'Le prénom est requis',
                    icon: Icons.person_outline,
                  ),
                  _buildStyledTextField(
                    label: 'Nom',
                    controller: lastnameController,
                    errorMessage: 'Le nom est requis',
                    icon: Icons.person_outline,
                  ),
                  _buildStyledTextField(
                    label: 'Email',
                    controller: emailController,
                    errorMessage: 'L\'email est requis',
                    icon: Icons.email_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Téléphone',
                    controller: phoneController,
                    errorMessage: 'Le téléphone est requis',
                    icon: Icons.phone_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Service',
                    controller: serviceController,
                    errorMessage: 'Le service est requis',
                    icon: Icons.business_center_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Localisation',
                    controller: locationController,
                    errorMessage: 'La localisation est requise',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 16, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 6),
                        const Text(
                          'Annuler',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        String firstName = firstnameController.text;
                        String lastName = lastnameController.text;
                        String email = emailController.text;
                        String phoneNumber = phoneController.text;
                        String location = locationController.text;
                        String service = serviceController.text;

                        User newUser = User(
                          firstName: firstName,
                          lastName: lastName,
                          email: email,
                          password: '',
                          phoneNumber: phoneNumber,
                          location: location,
                          authority: authority,
                          service: service,
                        );

                        Userservice.addUser(newUser).then((_) {
                          controller.fetchUsers();
                          Get.back();

                          Get.snackbar(
                            "Succès",
                            "Utilisateur ajouté avec succès",
                            margin: const EdgeInsets.all(10),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFF00C48C),
                            colorText: Colors.white,
                            borderRadius: 10,
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                        }).catchError((error) {
                          Get.snackbar(
                            "Erreur",
                            "$error",
                            margin: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFFFF6B6B),
                            colorText: Colors.white,
                            borderRadius: 10,
                            icon: const Icon(Icons.error_outline, color: Colors.white),
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FE5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Ajouter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyledTextField({
    required String label,
    required TextEditingController controller,
    required String errorMessage,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF4A6FE5), size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4A6FE5)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => (value == null || value.isEmpty) ? errorMessage : null,
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, dynamic user) {
    final formKey = GlobalKey<FormState>();

    final TextEditingController firstnameController = TextEditingController(text: user.firstName);
    final TextEditingController lastnameController = TextEditingController(text: user.lastName);
    final TextEditingController emailController = TextEditingController(text: user.email);
    final TextEditingController serviceController = TextEditingController(text: user.service);
    final TextEditingController locationController = TextEditingController(text: user.location);
    final TextEditingController phoneController = TextEditingController(text: user.phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FE5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF4A6FE5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Modifier utilisateur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6FE5),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledTextField(
                    label: 'Prénom',
                    controller: firstnameController,
                    errorMessage: 'Le prénom est requis',
                    icon: Icons.person_outline,
                  ),
                  _buildStyledTextField(
                    label: 'Nom',
                    controller: lastnameController,
                    errorMessage: 'Le nom est requis',
                    icon: Icons.person_outline,
                  ),
                  _buildStyledTextField(
                    label: 'Email',
                    controller: emailController,
                    errorMessage: 'L\'email est requis',
                    icon: Icons.email_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Service',
                    controller: serviceController,
                    errorMessage: 'Le service est requis',
                    icon: Icons.business_center_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Localisation',
                    controller: locationController,
                    errorMessage: 'La localisation est requise',
                    icon: Icons.location_on_outlined,
                  ),
                  _buildStyledTextField(
                    label: 'Téléphone',
                    controller: phoneController,
                    errorMessage: 'Le téléphone est requis',
                    icon: Icons.phone_outlined,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 16, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 6),
                        const Text(
                          'Annuler',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        User updatedUser = User(
                          id: user.id,
                          email: emailController.text,
                          firstName: firstnameController.text,
                          lastName: lastnameController.text,
                          phoneNumber: phoneController.text,
                          location: locationController.text,
                          password: '',
                          service: serviceController.text,
                          authority: user.authority ?? '',
                        );

                        bool result = await Userservice.editUser(user.id, updatedUser);

                        if (result) {
                          controller.fetchUsers();
                          Get.back();
                          Get.snackbar(
                            "Succès",
                            "Utilisateur modifié avec succès",
                            backgroundColor: const Color(0xFF00C48C),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 10,
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                          );
                        } else {
                          Get.snackbar(
                            "Erreur",
                            "Erreur lors de la modification",
                            backgroundColor: const Color(0xFFFF6B6B),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 10,
                            icon: const Icon(Icons.error_outline, color: Colors.white),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FE5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Modifier',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
void _showTechnicianDetailsDialog(BuildContext context, dynamic user) {
  showDialog(
    context: context,
    builder: (context) => TechnicianDetailsPage(user: user),
  );
}

void _showAssignEquipmentDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (context) => AssignEquipmentDialog(user: user),
  );
}
