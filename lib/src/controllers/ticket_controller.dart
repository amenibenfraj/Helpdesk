import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/models/Ticket.dart';
import 'package:helpdesk/src/service/TicketService.dart';

class TicketController extends GetxController {
  final storage = Get.find<sessionController>();
  var Tickets = <Ticket>[].obs;
  var TicketUser = <Ticket>[].obs;
  var TicketTech = <Ticket>[].obs;
  var filtredTicket = <Ticket>[].obs;
  var filtredTicketUserHelpdesk = <Ticket>[].obs;

  var filtredTicketTech = <Ticket>[].obs;
  var closedTickets = <Ticket>[].obs;

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final currentFilter = ''.obs;
  var searchQuery = ''.obs;
  late String title;
  var descController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<String> selectedFilePaths = <String>[].obs;
  File? selectedFile;
  var fileName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadTicketsByRole();
    loadTicketsByUserHelpdesk();
    fetchClosedTickets();
  }

  void searchTickets(String query) {
    if (query.isEmpty) {
      // Si la recherche est vide, on garde tous les tickets
      filtredTicket.value = Tickets;
    } else {
      filtredTicket.value = Tickets.where((ticket) {
        final lowerQuery = query.toLowerCase();
        return ticket.number.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  void searchTicketsUser(String query) {
    
      searchQuery.value = query;
    
  }



  void filterByStatus(String status) {
    currentFilter.value = status;
    if (status.isEmpty) {
      // Montrer tous les tickets
      filtredTicket.value = Tickets;
    } else {
      // Filtrer par statut
      filtredTicket.value =
          Tickets.where((ticket) => ticket.status == status).toList();
    }
  }
    void filterTicketTechByStatus(String status) {
    currentFilter.value = status;
    if (status.isEmpty) {
      // Montrer tous les tickets
      filtredTicketTech.value = TicketTech;
    } else {
      // Filtrer par statut
      filtredTicketTech.value =
          TicketTech.where((ticket) => ticket.status == status).toList();
    }
  }

  void filterTicketUserByStatus(String status) {
    currentFilter.value = status;
  }

  Future<void> loadTicketsByRole() async {
    try {
      String? role = await storage.readRole();
      print("role recuperé : $role");
      if (role == 'admin') {
        await fetchTickets();
      } else if (role == 'client') {
        await loadTicketsByUserHelpdesk();
      } else if (role == 'technician') {
        await loadTicketsByTechnician();
      }
    } catch (e) {
      print("Erreur lors de la lecture du role : $e");
      errorMessage.value = 'Erreur lors du chargement des tickets';
    }
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      Tickets.clear();
      List<Ticket>? fetchedTickets = await Ticketservice.getTotalTickets();
      filtredTicket.value = Tickets;
      //print("*********$fetchedTickets");

      if (fetchedTickets == null || fetchedTickets.isEmpty) {
        Tickets.clear();
        filtredTicket.clear();
        errorMessage.value = 'Aucun ticket trouvé';
      } else {
        errorMessage.value = '';

        // Mettre à jour les listes
        Tickets.assignAll(fetchedTickets);
        filtredTicket.assignAll(fetchedTickets);
      }
    } catch (error) {
      print("Erreur lors de la récupération des tickets: $error");
      errorMessage.value = 'Erreur lors du chargement des tickets: $error';

      // Important: vider les listes en cas d'erreur pour éviter d'afficher des données obsolètes
      Tickets.clear();
      filtredTicket.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'Not Assigned':
        return Colors.blueGrey;
      case 'Assigned':
        return const Color.fromARGB(255, 14, 125, 216);
      case 'Resolved':
        return const Color.fromARGB(255, 55, 139, 57);
      case 'Expired':
        return const Color.fromARGB(255, 245, 255, 105);
      case 'In Progress':
        return Colors.orange;
      case 'Deleted':
        return Colors.red;
      case 'Closed':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  void confirmDeleteTicket(BuildContext context, String idTicket) {
    descController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Center(
            child: Text(
              'Êtes-vous sûr(e) ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Voulez-vous vraiment supprimer ce ticket ?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Raison de suppression',
                  hintText: 'Entrez une raison...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                String reason = descController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Veuillez indiquer une raison."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                bool success =
                    await Ticketservice.deleteTicket(idTicket, reason);

                if (success) {
                  fetchTickets();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Échec de la suppression"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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

  Future<void> loadTicketsByUserHelpdesk() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      TicketUser.clear(); // Réinitialisation de la liste de tickets
      var tickets = await Ticketservice
          .getTicketByUserHelpdesk(); // Récupération des tickets
      TicketUser.assignAll(
          tickets ?? []); // Assignation directement à TicketUser

      if (tickets == null || tickets.isEmpty) {
        errorMessage.value =
            "Aucun ticket trouvé pour ce technicien"; // Message d'erreur si aucun ticket trouvé
      } else {
        errorMessage.value = '';
      }
    } catch (e) {
      print("Erreur : $e");
      errorMessage.value =
          "Erreur lors du chargement des tickets"; // Gestion des erreurs
      TicketUser.clear(); // En cas d'erreur, on réinitialise la liste
    } finally {
      isLoading.value = false; // Fin du chargement
    }
  }

  Future<void> loadTicketsByTechnician() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      TicketTech.clear();
      var tickets = await Ticketservice.getTicketByIdTech();

      // Mettre à jour les deux listes
      TicketTech.assignAll(tickets ?? []);
      filtredTicketTech.assignAll(tickets ?? []);

      if (tickets == null || tickets.isEmpty) {
        errorMessage.value = "Aucun ticket trouvé pour ce technicien";
      } else {
        errorMessage.value = ''; // Effacer les messages d'erreur précédents
      }
    } catch (e) {
      print("Erreur : $e");
      errorMessage.value = "Erreur lors du chargement des tickets";
      TicketTech.clear();
      filtredTicketTech.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void mangeTicket(String id, String idTech) async {
    bool take = await Ticketservice.manageTicket(id, idTech);
    if (take) {
      loadTicketsByTechnician();
    } else {
      Get.snackbar("Echec", "connot take this Ticket ");
    }
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple:
          true, // permet de sélectionner plusieurs fichiers à la fois
      type: FileType
          .any, // n'importe quel type de fichier est autorisé (.pdf, .jpg, .docx, etc.)
    );

    if (result != null && result.paths.isNotEmpty) {
      // Stockez seulement les chemins des fichiers
      selectedFilePaths.value = result.paths
          .where((path) => path != null)
          .map((path) => path!)
          .toList();
      // Notification optionnelle
      Get.snackbar('Fichiers sélectionnés',
          '${selectedFilePaths.length} fichiers prêts à être envoyés');
    }
  }

  Future<List<Ticket>> getRecentTickets() async {
    final userId = await storage.readId();
    if (userId == null) return [];

    final userTickets =
        TicketUser.where((ticket) => ticket.helpdeskUser?.id == userId)
            .toList()
            .reversed
            .take(3)
            .toList();

    return userTickets;
  }
//pour admin
Future<List<Ticket>> getLatestThreeTickets() async {
  try {
    // Récupérer tous les tickets en utilisant la méthode existante
    List<Ticket>? allTickets = await Ticketservice.getTotalTickets();
    
    // Vérifier si la liste est vide ou null
    if (allTickets == null || allTickets.isEmpty) {
      return [];
    }
    
    // Trier les tickets par date de création (du plus récent au plus ancien)
    allTickets.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    
    // Prendre les 3 premiers (plus récents)
    return allTickets.take(3).toList();
  } catch (error) {
    print("Erreur lors de la récupération des derniers tickets: $error");
    return [];
  }
}

  void fetchClosedTickets() async {
    isLoading(true);
    try {
      isLoading(true);
      var tickets = await Ticketservice.fetchClosedTickets();
      closedTickets.assignAll(tickets);
      filtredTicket.assignAll(tickets);
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchSimilarTickets(String query) async {
    try {
      isLoading.value = true;
      final List<Ticket> result =
          await Ticketservice.searchSimilarTickets(query);
      closedTickets.value = result; //  Important : update closedTickets
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), snackPosition: SnackPosition.BOTTOM);
      closedTickets.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
