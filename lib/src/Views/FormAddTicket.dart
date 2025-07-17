import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/ticket_controller.dart';
import 'package:helpdesk/src/service/adminService.dart';
import '../helpers/consts.dart';
import '../models/Equipement.dart';
import '../models/Problem.dart';
import '../models/User.dart';
import '../service/TpeEquipementService.dart';
import '../service/UserService.dart';

class AddTicketForm extends StatefulWidget {
  const AddTicketForm({Key? key}) : super(key: key);

  @override
  State<AddTicketForm> createState() => _AddTicketFormState();
}

class _AddTicketFormState extends State<AddTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TicketController controller = Get.find<TicketController>();

  String? _selectedTypeTicket;
  String? _selectedPriority;
  User? _selectedUser;
  Equipement? _selectedEquipment;
  Problem? _selectedProblem;
  bool _isOtherProblem = false;

  List<User> _users = [];
  List<Equipement> _equipments = [];
  List<Problem> _problems = [];

  final List<String> _typeTickets = ['equipment', 'service'];
  final List<String> _priorityLevels = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await Userservice.getAllUsers();
      if (users != null) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erreur chargement utilisateurs: $e');
    }
  }

  Future<void> _loadEquipments(String userId) async {
    try {
      final equipments = await Userservice.fetchEquipements(userId);
      if (equipments != null) {
        setState(() {
          _equipments = equipments;
          _selectedEquipment = null;
          _selectedProblem = null;
          _problems.clear();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erreur chargement équipements: $e');
    }
  }

  Future<void> _loadProblems(String typeId) async {
    try {
      final problems = await TypeEquipementservice.fetchTypeProblems(typeId);
      final other = Problem(id: 'other', nomProblem: 'Other');
      setState(() {
        if (problems.isNotEmpty) {
          _problems = problems.whereType<Problem>().toList();
          if (!_problems.any((p) => p.nomProblem == 'Other')) {
            _problems.add(other);
          }
        } else {
          _problems = [other];
        }
        _selectedProblem = null;
        _isOtherProblem = false;
      });
    } catch (e) {
      setState(() {
        _problems = [Problem(id: 'other', nomProblem: 'Other')];
      });
      _showErrorSnackBar('Erreur chargement problèmes: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Map pouvant contenir des valeurs dynamiques
      final Map<String, dynamic> ticketData = {
        'title': _titleController.text,
        'typeTicket': _selectedTypeTicket,
        'niveauEscalade': _selectedPriority,
        'helpdesk': _selectedUser!.id,
      };

      if (_selectedTypeTicket == 'equipment') {
        ticketData['problem'] = _selectedProblem?.nomProblem ?? 'Other';
        ticketData['description'] = _isOtherProblem
            ? _descriptionController.text
            : (_selectedProblem?.nomProblem ?? '');
        if (_selectedEquipment != null) {
          ticketData['equipmentHelpdesk'] = _selectedEquipment!.id;
        }
      } else {
        ticketData['problem'] = 'Service Request';
        ticketData['description'] = _descriptionController.text;
      }

      // Convertir les chemins de fichiers en objets File
      if (controller.selectedFilePaths.isNotEmpty) {
        List<File> files = controller.selectedFilePaths.map((path) => File(path)).toList();
        ticketData['files'] = files;
      }

      await Adminservice.createTicket(ticketData);
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Erreur création ticket: $e');
    }
  }
} 
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String? Function(T?)? validator,
    required Widget Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField2<T>(
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      isExpanded: true,
      value: value,
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: itemBuilder(e),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        maxHeight: 250,
        width: 250,
        offset: const Offset(0, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ajouter un Ticket',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                        ElevatedButton(
                      onPressed: controller.pickFile,
                      child: const Text("Choisir un fichier"),
                    ),
                    // Après le bouton "Choisir un fichier"
const SizedBox(height: 8),
Obx(() => controller.selectedFilePaths.isNotEmpty
  ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${controller.selectedFilePaths.length} fichier(s) sélectionné(s):',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...controller.selectedFilePaths.map((path) => Text(
          path.split('/').last,  // Afficher juste le nom du fichier
          overflow: TextOverflow.ellipsis,
        )).toList(),
      ],
    )
  : const SizedBox()),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Entrez un titre' : null,
                ),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  hint: 'Type de ticket',
                  value: _selectedTypeTicket,
                  items: _typeTickets,
                  onChanged: (val) {
                    setState(() {
                      _selectedTypeTicket = val;
                      _selectedEquipment = null;
                      _selectedProblem = null;
                      _isOtherProblem = false;
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Sélectionnez un type de ticket' : null,
                  itemBuilder: (e) => Text(e),
                ),
                const SizedBox(height: 12),
                _buildDropdown<String>(
                  hint: 'Priorité',
                  value: _selectedPriority,
                  items: _priorityLevels,
                  onChanged: (val) =>
                      setState(() => _selectedPriority = val),
                  validator: (val) =>
                      val == null ? 'Sélectionnez une priorité' : null,
                  itemBuilder: (e) => Text(e),
                ),
                const SizedBox(height: 12),
                _buildDropdown<User>(
                  hint: 'Utilisateur',
                  value: _selectedUser,
                  items: _users,
                  onChanged: (val) {
                    setState(() {
                      _selectedUser = val;
                      if (_selectedTypeTicket == 'equipment' && val != null) {
                        _loadEquipments(val.id);
                      }
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Sélectionnez un utilisateur' : null,
                  itemBuilder: (u) => Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(
                          "$serverUrl/uploads/${u.image?.fileName}",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${u.firstName} ${u.lastName}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedTypeTicket == 'equipment' && _selectedUser != null)
                  ...[
                    const SizedBox(height: 12),
                    _buildDropdown<Equipement>(
                      hint: 'Équipement',
                      value: _selectedEquipment,
                      items: _equipments,
                      onChanged: (val) {
                        setState(() {
                          _selectedEquipment = val;
                          if (val?.typeEquipment != null) {
                            _loadProblems(val!.typeEquipment!.id);
                          }
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Sélectionnez un équipement' : null,
                      itemBuilder: (e) => Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: e.typeEquipment?.logo?.fileName !=
                                    null
                                ? NetworkImage(
                                    '$serverUrl/uploads/${e.typeEquipment!.logo!.fileName}')
                                : null,
                            child: e.typeEquipment?.logo?.fileName == null
                                ? const Icon(Icons.devices_other, size: 14)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.designation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                if (_selectedEquipment != null)
                  ...[
                    const SizedBox(height: 12),
                    _buildDropdown<Problem>(
                      hint: 'Problème',
                      value: _selectedProblem,
                      items: _problems,
                      onChanged: (val) {
                        setState(() {
                          _selectedProblem = val;
                          _isOtherProblem = val?.nomProblem == 'Other';
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Sélectionnez un problème' : null,
                      itemBuilder: (p) => Text(p.nomProblem),
                    ),
                  ],
                if (_selectedTypeTicket == 'service' || _isOtherProblem)
                  ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty)
                              ? 'Veuillez fournir une description'
                              : null,
                    ),
                    const SizedBox(height: 8),
            
                  ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          iconColor: const Color.fromARGB(255, 170, 49, 41),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text(
                          'Close',
                          style: TextStyle(
                              color: Color.fromARGB(255, 170, 49, 41)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 19, 87, 143),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        label: const Text('creer',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
