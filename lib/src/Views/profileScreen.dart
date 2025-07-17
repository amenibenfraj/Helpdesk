import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/helpers/consts.dart';

import '../controllers/admin_controller.dart';
import '../helpers/utils.dart';

class ProfileScreen extends StatelessWidget {
  final AdminController controller = Get.find<AdminController>();
  final sessionController session = Get.find<sessionController>();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldKey,
      drawer: const MenuWidget(currentIndex: 7),
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

            // Main Content
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {},
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Profile title and navigation buttons
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 36),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                          const SizedBox(width:80 ),
                                            _buildTabButton(
                                              label: "Profile Details",
                                              isActive: true,
                                              onTap: () =>
                                                  Get.toNamed('/profile'),
                                            ),
                                          const SizedBox(width: 16),
                                            _buildTabButton(
                                              label: "Security",
                                              isActive: false,
                                              onTap: () =>
                                                  Get.toNamed('/securityadmin'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Main content in a white container
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Obx(() {
                                          if (controller.admin.value == null) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Color(0xFF4A6FE5),
                                            ));
                                          }

                                          final admin = controller.admin.value!;

                                          return Column(
                                            children: [
                                              Center(
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 50,
                                                      backgroundImage: controller
                                                                  .selectedImage
                                                                  .value !=
                                                              null
                                                          ? FileImage(controller
                                                              .selectedImage
                                                              .value!)
                                                          : (admin.image?.fileName !=
                                                                      null
                                                                  ? NetworkImage(
                                                                      '$serverUrl/uploads/${admin.image!.fileName}')
                                                                  : const AssetImage(
                                                                      "assets/images/adminPic.jpeg"))
                                                              as ImageProvider,
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: InkWell(
                                                        onTap: () => controller
                                                            .pickImage(),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFF4A6FE5),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                          ),
                                                          child: const Icon(
                                                            Icons.camera_alt,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Center(
                                                child: Text(
                                                  '${admin.firstname} ${admin.lastname}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF4A6FE5),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  admin.email,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 30),
                                              // Form fields
                                              Card(
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Wrap(
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    children: [
                                                      _buildProfileTextField(
                                                        controller: controller
                                                            .firstNameController,
                                                        label: "Firstname",
                                                      ),
                                                      _buildProfileTextField(
                                                        controller: controller
                                                            .lastNameController,
                                                        label: "Lastname",
                                                      ),
                                                      _buildProfileTextField(
                                                        controller: controller
                                                            .emailController,
                                                        label: "Email",
                                                      ),
                                                      _buildProfileTextField(
                                                        controller: controller
                                                            .phoneController,
                                                        label: "Phone Number",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 30),

                                              // Save button
                                              Center(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    bool success =
                                                        await controller
                                                            .updateAdmin(
                                                      controller
                                                          .emailController.text,
                                                      controller
                                                          .firstNameController
                                                          .text,
                                                      controller
                                                          .lastNameController
                                                          .text,
                                                      controller
                                                          .phoneController.text,
                                                      controller
                                                          .selectedImage.value,
                                                    );
                                                    if (success) {
                                                      controller
                                                          .getProfileAdmin();
                                                    }
                                                  },
                                                  label: const Text(
                                                    "modifier",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF4A6FE5),
                                                    elevation: 3,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4A6FE5) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return SizedBox(
      width: 350,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A6FE5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
