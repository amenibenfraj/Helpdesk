import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

import '../helpers/consts.dart';
import '../models/Admin.dart';
import 'package:mime/mime.dart';

class Adminservice {
  static Future<Admin?> getAdmin() async {
    final storage = FlutterSecureStorage();
    String? id_admin = await storage.read(key: USER_ID);
    String? role = await storage.read(key: USER_ROLE);

    print("id***:  $id_admin  ,role: $role");
    if (id_admin == null) {
      print("aucun id trouvé dans secure storage");
      return null; // Pas d'admin connecté
    }

    try {
      final response =
          await http.get(Uri.parse("$serverUrl/admin/getAdminById/$id_admin"));

      if (response.statusCode == 200) {
        return Admin.fromJson(jsonDecode(response.body));
      } else {
        print("Erreur : ${response.statusCode}");
        print("Erreur ***********: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception lors de la récupération  admin: $e");
      return null;
    }
  }

  static Future<bool> updateAdmin(String id, String email, String firstName,
      String lastName, String phoneNumber, File? image) async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: ACCESS_TOKEN);

    print("AccessToken : $accessToken");

    var request = http.MultipartRequest(
        "PUT", Uri.parse("$serverUrl/admin/updateAdmin/$id"));

    // Ajouter les champs au corps de la requête
    request.fields['email'] = email;
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['phoneNumber'] = phoneNumber;

    // Vérifier si une image est sélectionnée
    if (image != null) {
      // Vérifier le type MIME du fichier
      String? mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        Get.snackbar(
            "Erreur", "Le fichier sélectionné n'est pas une image valide");
        return false;
      }

      print("Ajout de l'image : ${image.path}");
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    // Ajouter l'en-tête d'autorisation
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print("********Admin mis à jour avec succès");
        return true;
      } else {
        print("Erreur lors de la mise à jour admin: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception lors de la mise à jour: $e");
      return false;
    }
  }

  static Future<void> createTicket(Map<String, dynamic> ticketData) async {
    try {
      List<File> files = [];
      if (ticketData.containsKey('files')) {
        files = ticketData['files'] as List<File>;
        ticketData.remove('files'); // ne pas envoyer ça dans le JSON
      }

      if (files.isEmpty) {
        // Envoi standard sans fichier
        final response = await http.post(
          Uri.parse('$serverUrl/admin/createTicketHelpDesk'),
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
          Uri.parse('$serverUrl/admin/createTicketHelpDesk'),
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
}
