import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/Equipement.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class Userservice {
  //all users
  static Future<List<User>?> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/user/all'));

      if (response.statusCode == 200) {
        List<dynamic> listData =
            jsonDecode(response.body); //  la réponse est une liste

        //  convertir chaque élément en un objet User avec map
        List<User> users = listData.map((element) {
          return User.fromJson(element as Map<String, dynamic>);
        }).toList();
        return users;
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur: $e');
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

//all equipement d'un user
  static Future<List<Equipement>?> fetchEquipements(String idUser) async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/user/getUserById/$idUser'),
      );
      //print(response.body); // Affiche le corps de la réponse pour déboguer
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérifier si 'listEquipment' existe et contient des équipements
        List<dynamic> equipements = data['listEquipment'] ?? [];
        if (equipements.isEmpty) {
          //print('Aucun équipement trouvé');
          return [];
        }
        var a = equipements.map((e) {
          var equip = Equipement.fromJson(e);

          return equip;
        }).toList();

        return a;
      } else {
        print('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur lors de la récupération des équipements : $e");
    }
    return null; // Retourner null en cas d'erreur
  }

//modifier user
  static Future<bool> updateUser(String id, String email, String firstName,
      String lastName,String location, String phoneNumber, File? image) async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: ACCESS_TOKEN);

    print("AccessToken : $accessToken");

    var request = http.MultipartRequest(
        "PUT", Uri.parse("$serverUrl/user/updateUser/$id"));

    // Ajouter les champs au corps de la requête
    request.fields['email'] = email;
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['phoneNumber'] = phoneNumber;
    request.fields['location'] = location;

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
        print("********User mis à jour avec succès");
        return true;
      } else {
        print("Erreur lors de la mise à jour User: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception lors de la mise à jour: $e");
      return false;
    }
  }

//add user(client)
  static Future<String> addUser(User newUser) async {
    try {
      final body = jsonEncode({
        "firstName": newUser.firstName,
        "lastName": newUser.lastName,
        "email": newUser.email,
        "phoneNumber": newUser.phoneNumber,
        "status": newUser.status,
        "service": newUser.service,
        "location": newUser.location
      });

      final headers = {
        'Content-Type': 'application/json',
      };
      final res = await http.post(Uri.parse('$serverUrl/user/createUser'),
          headers: headers, body: body);
      if (res.statusCode == 200) {
        return "User added with succes";
      } else {
        final errorResponse = jsonDecode(res.body);
        return "Failed to add user: ${errorResponse['message']}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

//change pwd
  static Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final storage = FlutterSecureStorage();
      String? id = await storage.read(key: USER_ID);
      String? rolepassword = await storage.read(key: USER_ROLE);
      final body = jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'rolepassword': rolepassword
      });

      final response = await http.post(
          Uri.parse("$serverUrl/user/changePassword/$id"),
          headers: {'Content-Type': 'application/json'},
          body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        print("Failed to change password: ${errorResponse['message']}");
        return false;
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      return false;
    }
  }

//Get User By Id
  static Future<User?> getUser() async {
    final storage = FlutterSecureStorage();
    String? id_user = await storage.read(key: USER_ID);

    // print("id***:  $id_user  ,role: $role");
    if (id_user == null) {
      print("aucun id trouvé dans secure storage");
      return null;
    }

    try {
      final response =
          await http.get(Uri.parse("$serverUrl/user/getUserById/$id_user"));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print("Erreur : ${response.statusCode}");
        print("Erreur ***********: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception lors de la récupération  user: $e");
      return null;
    }
  }

static Future<bool> updateStatUser(String idUser, bool valid) async {
    try {
      

          final response = await http.put(Uri.parse("$serverUrl/user/updateStatUser"),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'_id': idUser, 'valid': valid}));
              //print("reponse serveur: ${response.statusCode} - ${response.body}");

              if (response.statusCode == 200) {
                return true;
              } else {
                print('Erreur: ${response.body}');
                return false;
              }
    } catch (error) {
      print("erreur: $error");
      return false;
    }
   
  }

static Future<bool> editUser(String userId,User user) async {
    try {
      
      var response = await http.put(
        Uri.parse("$serverUrl/user/updateUser/$userId"), 

        headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': user.email,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phoneNumber': user.phoneNumber,
        'location': user.location,
        'service':user.service
      }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur de mise à jour : ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour : $e');
      return false;
    }
  }
}
