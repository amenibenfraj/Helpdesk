import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../controllers/ticket_controller.dart';
import '../models/Ticket.dart';
import '../service/TicketService.dart';

class UpdateTicketForm extends StatefulWidget {
  final Ticket ticket;

  const UpdateTicketForm({Key? key, required this.ticket}) : super(key: key);

  @override
  State<UpdateTicketForm> createState() => _UpdateTicketFormState();
}

class _UpdateTicketFormState extends State<UpdateTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TicketController ticketController = Get.find<TicketController>();
  String? _selectedPriority;
  // String? _selectedStatus;

  bool _isLoading = false;

  final List<String> _priorityLevels = ['High', 'Medium', 'Low'];
  //final List<String> _statusOptions = ['In Progress', 'Resolved', 'Closed', 'Not Assigned', 'Deleted'];

  @override
  void initState() {
    super.initState();
    _initializeFormWithTicketData();
  }

  void _initializeFormWithTicketData() {
    _titleController.text = widget.ticket.title;
    _descriptionController.text = widget.ticket.description;

    _selectedPriority = _priorityLevels.contains(widget.ticket.niveauEscalade)
        ? widget.ticket.niveauEscalade
        : _priorityLevels.first;

    // _selectedStatus = _statusOptions.contains(widget.ticket.status)
    //     ? widget.ticket.status
    //     : _statusOptions.first;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "Erreur",
      message,
      backgroundColor: const Color(0xFFFF6B6B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      "Succès",
      message,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final ticketData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'niveauEscalade': _selectedPriority,
          //'status': _selectedStatus,
        };

        final success =
            await Ticketservice.updateTicket(widget.ticket.id, ticketData);

        if (success) {
          ticketController.fetchTickets();
          _showSuccessSnackBar('Ticket mis à jour avec succès');
          Navigator.pop(context, true);
        } else {
          _showErrorSnackBar('Échec de la mise à jour du ticket');
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la mise à jour du ticket: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStyledTextField({
    required String label,
    required TextEditingController controller,
    required String errorMessage,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A6FE5)),
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4A6FE5), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return errorMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStyledDropdown2({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String errorMessage,
    required IconData icon,
    bool isRequired = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField2<String>(
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A6FE5)),
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4A6FE5), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return errorMessage;
          }
          return null;
        },
        buttonStyleData: const ButtonStyleData(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A6FE5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Color(0xFF4A6FE5), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Modifier un ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A6FE5),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A6FE5)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A6FE5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStyledTextField(
                          label: 'Titre',
                          controller: _titleController,
                          errorMessage: 'Veuillez entrer un titre',
                          icon: Icons.title,
                        ),
                        _buildStyledTextField(
                          label: 'Description',
                          controller: _descriptionController,
                          errorMessage: 'Veuillez fournir une description',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        _buildStyledDropdown2(
                          label: 'Priorité',
                          value: _selectedPriority,
                          items: _priorityLevels,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                          errorMessage: 'Veuillez sélectionner une priorité',
                          icon: Icons.priority_high,
                        ),
                        // _buildStyledDropdown2(
                        //   label: 'Statut',
                        //   value: _selectedStatus,
                        //   items: _statusOptions,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _selectedStatus = value;
                        //     });
                        //   },
                        //   errorMessage: 'Veuillez sélectionner un statut',
                        //   icon: Icons.hourglass_bottom,
                        // ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: const Color(0xFFFF6B6B)
                                            .withOpacity(0.5)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.close,
                                        size: 16, color: Color(0xFFFF6B6B)),
                                    SizedBox(width: 6),
                                    Text(
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
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A6FE5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text(
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
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
