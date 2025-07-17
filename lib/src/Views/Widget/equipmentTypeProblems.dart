import 'package:flutter/material.dart';

import '../../models/Problem.dart';
import '../../service/TpeEquipementService.dart';

class EquipmentTypeProblems extends StatefulWidget {
  final String idType;

  const EquipmentTypeProblems({Key? key, required this.idType}) : super(key: key);

  @override
  State<EquipmentTypeProblems> createState() => _EquipmentTypeProblemsState();
}

class _EquipmentTypeProblemsState extends State<EquipmentTypeProblems> {
  late Future<List<Problem?>> problemsFuture;
  final TextEditingController nomProblemController = TextEditingController();
  final TextEditingController descProblemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  void _fetchProblems() {
    setState(() {
      problemsFuture = TypeEquipementservice.fetchTypeProblems(widget.idType);
    });
  }

  Future<void> _addProblem() async {
    if (nomProblemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un problème")),
      );
      return;
    }

    final problem = Problem(
      id: '',
      nomProblem: nomProblemController.text,
      description: descProblemController.text,
    );
    final success = await TypeEquipementservice.addProblemToType(widget.idType, problem);

    if (success) {
      Navigator.of(context).pop();
      _fetchProblems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'ajout du problème !"), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddProblemForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              'Ajouter un Problème',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildStyledTextField(
                    label: 'Nom du Problème',
                    controller: nomProblemController,
                    errorMessage: 'Le nom est requis',
                  ),
                  _buildStyledTextField(
                    label: 'Description',
                    controller: descProblemController,
                    errorMessage: 'La description est requise',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Color.fromARGB(255, 170, 49, 41))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _addProblem();
                            nomProblemController.clear();
                            descProblemController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 19, 87, 143),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Enregistrer", style: TextStyle(color: Color.fromARGB(255, 150, 186, 216))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProblemForm(String problemId) {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              'Modifier le Problème',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildStyledTextField(
                    label: 'Nom du Problème',
                    controller: nomProblemController,
                    errorMessage: 'Le nom est requis',
                  ),
                  _buildStyledTextField(
                    label: 'Description',
                    controller: descProblemController,
                    errorMessage: 'La description est requise',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Color.fromARGB(255, 170, 49, 41))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _editProblem(problemId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 19, 87, 143),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Modifier", style: TextStyle(color: Color.fromARGB(255, 150, 186, 216))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField({required String label, required TextEditingController controller, required String errorMessage}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color.fromARGB(255, 224, 217, 217),
        ),
        validator: (value) => (value == null || value.isEmpty) ? errorMessage : null,
      ),
    );
  }

  Future<void> _editProblem(String problemId) async {
    final problem = Problem(id: problemId, nomProblem: nomProblemController.text, description: descProblemController.text);
    bool success = await TypeEquipementservice.updateProblem(problem);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mise à jour réussie"), backgroundColor: Colors.teal),
      );
      Navigator.of(context).pop();
      _fetchProblems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mise à jour échouée"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Problèmes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAddProblemForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Problem?>>(
              future: problemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Erreur : \${snapshot.error}", style: const TextStyle(color: Colors.red)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Aucun problème trouvé !', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final problem = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(problem?.nomProblem ?? 'Problème inconnu', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(problem?.description ?? 'Pas de description', style: const TextStyle(color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Color.fromARGB(255, 30, 161, 18)),
                                onPressed: () {
                                  nomProblemController.text = problem?.nomProblem ?? '';
                                  descProblemController.text = problem?.description ?? '';
                                  _showEditProblemForm(problem!.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _confirmDeleteProblem(context, problem!.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProblem(BuildContext context, String problemId) {
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
          "Voulez-vous vraiment supprimer ce problème ?",
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
            onPressed: () async {
              Navigator.of(context).pop();
              bool success = await TypeEquipementservice.deleteProblem(problemId);
              if (success) {
                _fetchProblems();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Suppression échouée"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
}
