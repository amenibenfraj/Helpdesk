import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/technician_controller.dart';

class SignUpPage extends StatefulWidget {
  final TechnicianController controller = Get.find<TechnicianController>();

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
            // Background circles
            Positioned(
              left: -30,
              top: 100,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 150,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 120,
              top: 180,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Get Started",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            // Profile picture
                            Center(
                              child: Column(
                                children: [
                                  Obx(() {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                        image: widget.controller.selectedImage.value != null
                                            ? DecorationImage(
                                                image: FileImage(File(widget.controller.selectedImage.value!.path)),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: AssetImage('assets/images/default_user.jpeg'),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      child: widget.controller.selectedImage.value == null
                                          ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                                          : null,
                                    );
                                  }),
                                  SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await widget.controller.pickImage();
                                    },
                                    
                                    label: Text("Add Photo"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Form Container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Form(
                                key: widget.controller.formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabeledField(
                                      label: "Full Name",
                                      color: Colors.blue[700]!,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: widget.controller.firstNameController,
                                              decoration: _inputDecoration(
                                                hintText: 'First Name',
                                                prefixIcon: Icons.person_outline,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: widget.controller.lastNameController,
                                              decoration: _inputDecoration(
                                                hintText: 'Last Name',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Email",
                                      color: Colors.blue[700]!,
                                      child: TextFormField(
                                        controller: widget.controller.emailController,
                                        decoration: _inputDecoration(
                                          hintText: 'your.email@example.com',
                                          prefixIcon: Icons.email_outlined,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                          RegExp regex = RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            return 'Invalid email format';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Password",
                                      color: Colors.blue[700]!,
                                      child: TextFormField(
                                        controller: widget.controller.passwordController,
                                        obscureText: true,
                                        decoration: _inputDecoration(
                                          hintText: '••••••••',
                                          prefixIcon: Icons.lock_outline,
                                        ),
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Confirm Password",
                                      color: Colors.blue[700]!,
                                      child: TextFormField(
                                        controller: widget.controller.confirmPasswordController,
                                        obscureText: true,
                                        decoration: _inputDecoration(
                                          hintText: '••••••••',
                                          prefixIcon: Icons.lock_outline,
                                        ),
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Role",
                                      color: Colors.blue[700]!,
                                      child: DropdownButtonFormField<String>(
                                        value: widget.controller.selectedRole,
                                        items: [
                                          DropdownMenuItem(value: 'technician', child: Text('Technician')),
                                        ],
                                        onChanged: (newValue) {
                                          setState(() {
                                            widget.controller.selectedRole = newValue;
                                          });
                                        },
                                        decoration: _inputDecoration(
                                          hintText: 'Select Role',
                                          prefixIcon: Icons.assignment_ind_outlined,
                                        ),
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Phone Number",
                                      color: Colors.blue[700]!,
                                      child: TextFormField(
                                        controller: widget.controller.phoneNumberController,
                                        decoration: _inputDecoration(
                                          hintText: '+1 (234) 567-8901',
                                          prefixIcon: Icons.phone_outlined,
                                        ),
                                      ),
                                    ),
                                    _buildLabeledField(
                                      label: "Service",
                                      color: Colors.blue[700]!,
                                      child: TextFormField(
                                        controller: widget.controller.serviceController,
                                        decoration: _inputDecoration(
                                          hintText: 'Your department or service',
                                          prefixIcon: Icons.business_center_outlined,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: widget.controller.submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size(double.infinity, 45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
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

  Widget _buildLabeledField({
    required String label,
    required Widget child,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[500], size: 20) : null,
      isDense: true,
    );
  }
}