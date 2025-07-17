import 'dart:convert';

import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/technician.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../Views/login.dart';

import '../controllers/user_controller.dart';
import '../models/User.dart';


class Authservice {
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final storage = Get.find<sessionController>();

    try {
      final response = await http.post(
        Uri.parse("$serverUrl/auth/login"),
        headers: headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String userId = data['payload']['user']['_id'];
        String accessToken = data[ACCESS_TOKEN];
        String refreshToken = data[REFRESH_TOKEN];

        // Extraire le rôle à partir du token (1 seule fois ici)
        final parts = accessToken.split('.');
        final payload =
            jsonDecode(utf8.decode(base64.decode(base64.normalize(parts[1]))));
        final role = payload['authority'];

        // Stocker les infos localement
        await storage.writeToken(accessToken);
        await storage.writeRefToken(refreshToken);
        await storage.writeId(userId);
        await storage.writeRole(role);
        

        // Mettre à jour GetX
        Get.find<UserController>().setUser(User.fromJson(data['payload']['user']));
        Get.find<UserController>().loadUserId();
        // Appel à une méthode pour connecter l'utilisateur à son socketId
      //await SocketService.registerUserSocket(userId);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }

  static Future<void> logout() async {
    final storage = Get.find<sessionController>();
    await storage.deleteSession();
    final userController = Get.find<UserController>();
    userController.userId.value = '';
    Get.offAll(() => LoginScreen());
    return;
  }

  static Future<int> register(Technician technicien) async {
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse("$serverUrl/auth/register")); //.parse converti une chaine en objet Uri

      // Ajouter les champs JSON normaux
      request.fields['firstName'] = technicien.firstName;
      request.fields['lastName'] = technicien.lastName;
      request.fields['email'] = technicien.email;
      request.fields['password'] = technicien.password;
      request.fields['authority'] = technicien.authority;
      request.fields['phoneNumber'] = technicien.phoneNumber!;
      request.fields['service'] = technicien.service;

      // Vérifier si une image est sélectionnée
      if (technicien.image != null) {
        //print("Chemin de l'image : ${technicien.image!.path}");

        if (technicien.image!.path.isEmpty) {
          //print("Le cheminest vide !");
        } else {
          String? mimeType = lookupMimeType(technicien.image!.path);
          // print("MIME Type détecté : $mimeType");

          if (mimeType == null || !mimeType.startsWith('image/')) {
            //print("Erreur : Le fichier sélectionné n'est pas une image valide");
            return 400;
          }

          request.files.add(await http.MultipartFile.fromPath(
            // (fromPath) utilisée pour charger un fichier à partir d’un chemin local
            'profilePicture', // champ envoyé dans la requête
            technicien.image!.path, // Chemin du fichier
            contentType: MediaType.parse(mimeType), // Type MIME du fichier
          ));
        }
      } else {
        print("technicien.image est NULL !");
      }

      // Envoyer la requête

      var response = await request.send();

      // Log de la réponse
      //print("Statut de la requête : ${response.statusCode}");
      //String responseBody = await response.stream.bytesToString();
      //print("Réponse du serveur : $responseBody");

      return response.statusCode;
    } catch (error) {
      print("Erreur lors de l'inscription du technicien: $error");
      return 500;
    }
  }
}
