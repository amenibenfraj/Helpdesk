import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/Ticket.dart';
import 'TechService.dart';

class Ticketservice {
  static Future<List<Ticket>?> getTotalTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Vérifier si la réponse contient une erreur
        if (data["err"] == true) {
          print("Erreur API: ${data["message"]}");
          return [];
        }

        // S'assurer que le champ "rows" existe
        if (!data.containsKey("rows")) {
          print("La réponse ne contient pas de champ 'rows'");
          return [];
        }

        List<dynamic> tickets = data["rows"];
        return tickets.map((ele) => Ticket.fromJson(ele)).toList();
      } else {
        throw Exception("Failed to load tickets");
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<int> getAllTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tickets = data["rows"];

        return tickets.length;
      } else {
        print(
            "Erreur lors de la récupération des tickets : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Exception : $e");
      return 0;
    }
  }

  static Future<List<Ticket>?> getTicketByUserHelpdesk() async {
    final storage = Get.find<sessionController>();
    String? idUser = await storage.readId();
    try {
      final response = await http
          .get(Uri.parse("$serverUrl/ticket/getTicketByUserHelpdesk/$idUser"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> tickets = data["rows"];
        return tickets.map((ele) => Ticket.fromJson(ele)).toList();
      } else {
        throw Exception("Failed to load tickets ");
      }
    } catch (err) {
      //print("Exception in getTotalTickets: $e");
      throw err;
    }
  }

  static Future<void> createTicket(Map<String, dynamic> ticketData) async {
    try {
      List<File> files = [];
      if (ticketData.containsKey('files')) {
        files = ticketData['files'] as List<File>;
        ticketData.remove('files');
      }

      if (files.isEmpty) {
        // Envoi standard sans fichier
        final response = await http.post(
          Uri.parse('$serverUrl/ticket/createTicketHelpDesk'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(ticketData),
        );

        if (response.statusCode != 200) {
          final errorData = jsonDecode(response.body);
          throw Exception(
              errorData['message'] ?? 'Erreur lors de la création du ticket');
        }
      } else {
        // Envoi multipart avec fichiers
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$serverUrl/ticket/createTicketHelpDesk'),
        );

        // Ajouter les données JSON sous forme de champ
        request.fields['helpdesk'] = ticketData['helpdesk'];
        request.fields['title'] = ticketData['title'];
        request.fields['typeTicket'] = ticketData['typeTicket'];
        request.fields['niveauEscalade'] = ticketData['niveauEscalade'];
        request.fields['problem'] = ticketData['problem'];
        request.fields['description'] = ticketData['description'];
        if (ticketData['equipmentHelpdesk'] != null) {
          request.fields['equipmentHelpdesk'] = ticketData['equipmentHelpdesk'];
        }

        // Ajouter chaque fichier au champ 'files'
        for (File file in files) {
          String fileName = file.path.split('/').last;
          String mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';

          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType.parse(mimeType),
            filename: fileName,
          ));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          final errorData = jsonDecode(response.body);
          throw Exception(
              errorData['message'] ?? 'Erreur lors de la création du ticket');
        }
      }
    } catch (e) {
      print('*****$e');
      throw Exception('Erreur lors de la création du ticket: $e');
    }
  }

  static Future<int> getInProgressTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> tickets = data['rows'];
        int count =
            tickets.where((ticket) => ticket['status'] == 'In Progress').length;
        return count;
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Erreur dans getInProgressTickets: $e");
      return 0;
    }
  }

  static Future<int> getResolvedTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> tickets = data['rows'];

        int count =
            tickets.where((ticket) => ticket['status'] == 'Resolved').length;
        return count;
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Erreur lors du getResolvedTickets: $e");
      return 0;
    }
  }

  static Future<int> getExpiredTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> tickets = data['rows'];
        int count =
            tickets.where((ticket) => ticket['status'] == 'Expired').length;
        return count;
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Erreur dans getExpiredTickets: $e");
      return 0;
    }
  }

  static Future<int> getClosedTickets() async {
    try {
      final response =
          await http.get(Uri.parse("$serverUrl/ticket/getAllTickets"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> tickets = data['rows'];
        int count =
            tickets.where((ticket) => ticket['status'] == 'Closed').length;
        return count;
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Erreur dans getClosedTickets: $e");
      return 0;
    }
  }

  static Future<bool> deleteTicket(String idTicket, String description) async {
    try {
      final response = await http.put(
          Uri.parse("$serverUrl/ticket/deleteTicket"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"id": idTicket, "description": description}));
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print("error: $e");
      return false;
    }
  }

  static Future<bool> assignTechnicianToTicket(
    String idTicket,
    List<String> technicianIds,
  ) async {
    try {
      final ticket = await http.get(Uri.parse("$serverUrl/ticket/$idTicket"));

      if (ticket.statusCode == 200) {
        final ticketData = jsonDecode(ticket.body);
        if (ticketData["status"] != "Not Assigned") {
          Get.snackbar(
              "echec", "Le ticket n'est pas dans l'état 'Not Assigned'");
          return false;
        }
      }
      final response = await http.patch(
          Uri.parse("$serverUrl/ticket/assignTicket"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'_id': idTicket, 'technicienId': technicianIds}));
      //  print("response: ${response.body}");
      if (response.statusCode == 200) {
        jsonEncode({'_id': idTicket, 'technicienId': technicianIds});
        return true;
      } else {
        print("erreur: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur lors de l'affectation du technicien: $e");
      return false;
    }
  }

  static Future<bool> saveSolution(
      {required String ticketId,
      required String solution,
      required List<File> files}) async {
    try {
      var uri = Uri.parse('$serverUrl/ticket/saveSolution');
      var request = http.MultipartRequest('POST', uri);

      // Ajouter les champs
      request.fields['ticketId'] = ticketId;
      request.fields['solution'] = solution;

      // Ajouter le fichier si présent
      for (var file in files) {
        String fileName = file.path.split('/').last;
        String mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: MediaType.parse(mimeType),
          filename: fileName,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur lors de l\'envoi : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur générale saveSolution : $e');
      return false;
    }
  }

  static Future<bool> validateSolution(String id) async {
    try {
      final response = await http.post(
          Uri.parse("$serverUrl/ticket/validateSolution"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'ticketId': id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("error:  $error");
      return false;
    }
  }

  static Future<List<Ticket>?> getTicketByIdTech() async {
    final storage = Get.find<sessionController>();

    try {
      String? idTech = await storage.readId();

      String url = "$serverUrl/ticket/getTicketByTechId/$idTech";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> tickets = data["rows"];

        // Conversion en objets Ticket
        return tickets.map((json) => Ticket.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> manageTicket(String idTicket, String technicianId) async {
    try {
      final response = await http.put(
          Uri.parse("$serverUrl/ticket/manageTicket"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'_id': idTicket, 'technicienId': technicianId}));
      if (response.statusCode == 200) {
        return true;
      } else {
        print("echec take this tiket ");
        return false;
      }
    } catch (e) {
      print("erreur: $e");
      return false;
    }
  }

  static Future<int> getActiveTechnicians() async {
    final allTechs = await Techservice.getTechnicians();
    return allTechs!.where((tech) => tech.valid == true).length;
  }

  static Future<int> getResolvedTicketsCount() async {
    final allTickets = await getTotalTickets();
    return allTickets!.where((ticket) => ticket.status == 'Resolved').length;
  }

  static Future<int> getLevel1TicketsCount() async {
    final allTickets = await getTotalTickets();
    return allTickets!
        .where((ticket) => ticket.niveauEscalade == 'level1')
        .length;
  }

  static Future<int> getLevel2TicketsCount() async {
    final allTickets = await getTotalTickets();
    return allTickets!
        .where((ticket) => ticket.niveauEscalade == 'level2')
        .length;
  }

  static Future<int> getLevel3TicketsCount() async {
    final allTickets = await getTotalTickets();
    return allTickets!
        .where((ticket) => ticket.niveauEscalade == 'level3')
        .length;
  }

  static Future<Ticket> getTicketById(String id) async {
    try {
      final response =
          await http.get(Uri.parse('$serverUrl/ticket/getTicketById/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Map<String, dynamic> jsonTicket = json['rows'];
        Ticket myTicket = Ticket.fromJson(jsonTicket);
        return myTicket;
      } else {
        Map<String, dynamic> json = jsonDecode(response.body);
        String str = json['message'];
        throw Exception('Erreur getTicketById $str');
      }
    } catch (e) {
      print('ERREUR LORS DE LA RECUPERATION D\'UN TICKET : $e ');
      throw Exception('ERREUR LORS DE LA RECUPERATION D\'UN TICKET : $e ');
    }
  }

  static Future<List<Ticket>?> getClosedTicketsObjects() async {
    try {
      final allTickets = await getTotalTickets();
      if (allTickets == null) return [];

      return allTickets.where((ticket) => ticket.status == 'Closed').toList();
    } catch (e) {
      print("Erreur dans getClosedTicketsObjects: $e");
      return [];
    }
  }

  static Future<List<Ticket>?> getResolvedTicketsObjects() async {
    try {
      final allTickets = await getTotalTickets();
      if (allTickets == null) return [];

      return allTickets.where((ticket) => ticket.status == 'Resolved').toList();
    } catch (e) {
      print("Erreur dans getResolvedTicketsObjects: $e");
      return [];
    }
  }

  static Future<List<Ticket>?> getInProgressTicketsObjects() async {
    try {
      final allTickets = await getTotalTickets();
      if (allTickets == null) return [];

      return allTickets
          .where((ticket) => ticket.status == 'In Progress')
          .toList();
    } catch (e) {
      print("Erreur dans getInProgressTicketsObjects: $e");
      return [];
    }
  }

 static Future<List<Ticket>> fetchClosedTickets() async {
  try {
  final response = await http.get(Uri.parse('$serverUrl/ticket/getAllClosedTickets'));
  print('STATUS CODE: ${response.statusCode}');
  print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ticketsJson = data['rows'];
      return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
    } else {
      final data = jsonDecode(response.body);
      String str=data['message'];
      print("JJJJJJJJJJJJJJJJJJJJJJJJJJJ : $str");
      throw Exception('Failed to load closed tickets :  $str');

    }
  }catch (e) {
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA$e");
    throw Exception('Failed to load closed tickets EXCEPTION $e');
  }
}
static Future<List<Ticket>> searchSimilarTickets(String query) async {
  try {
    final url = Uri.parse('$serverUrl/search/getSimilarTickets');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'top_k': 3,
        'threshold': 0.5,
      }),
    );

    print("Réponse brute de la recherche intelligente : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['rows'] ;

      // Mapping des résultats vers une liste de Ticket
      List<Ticket> tickets = results.map((json) => Ticket.fromJson(json)).toList();

      return tickets;
    } else {
      throw Exception(
          'Erreur lors de la recherche contextuelle : ${response.body}');
    }
  } catch (e) {
    print("Erreur lors de la recherche : $e");
    throw Exception("Exception lors de la recherche : $e");
  }
}

 static Future<bool> updateTicket(String ticketId, Map<String, dynamic> ticketData) async {
  try {
    final updateData = {
      '_id':ticketId,
      'title': ticketData['title'],
      'description': ticketData['description'],
      'niveauEscalade': ticketData['niveauEscalade'],
      //'status': ticketData['status'],
    };

    // Envoyer la requête de mise à jour avec l'ID dans l'URL
    final response = await http.put(
      Uri.parse('$serverUrl/ticket/updateTicket'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Erreur lors de la mise à jour du ticket');
    }

    return true;
  } catch (e) {
    print('Erreur lors de la mise à jour du ticket: $e');
    return false;
  }
}}
