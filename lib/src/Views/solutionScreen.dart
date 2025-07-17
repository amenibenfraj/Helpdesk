import 'package:flutter/material.dart';


class SolutionScreen extends StatefulWidget {
  final String ticketId;

  SolutionScreen({required this.ticketId});

  @override
  _SolutionScreenState createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  String solutionText = '';
  List<String> fileNames = [];

  @override
  void initState() {
    super.initState();
    loadSolution();
  }

  Future<void> loadSolution() async {
    try {
      //final solution = await Ticketservice.getSolution(widget.ticketId);
      // if (solution != null) {
      //   setState(() {
      //     solutionText = solution.text;
      //     fileNames = solution.files ?? [];
      //   });
      // }
    } catch (e) {
      print("Erreur lors du chargement de la solution : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solution du ticket")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: solutionText.isEmpty
            ? Center(child: Text("Aucune solution n'a été soumise."))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Solution :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(solutionText),
                  SizedBox(height: 20),
                  if (fileNames.isNotEmpty)
                    Text("Fichiers joints :", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...fileNames.map((f) => Text("📎 $f")).toList(),
                ],
              ),
      ),
    );
  }
}
