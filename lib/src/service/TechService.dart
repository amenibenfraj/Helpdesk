import 'dart:convert';

import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/technician.dart';
import 'package:http/http.dart';

class Techservice {
  //allTechniciens
  static Future<List<Technician>?> getTechnicians() async {
    final response = await get(Uri.parse('$serverUrl/tech/getListTechnician'));
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      final List l = data['rows'];
      //convertir la liste de json récupérée depuis l'API en une liste d'Objets dart
      return l.map((ele) => Technician.fromJson(ele)).toList();
    } else {
      String strError = data["message"];
      throw Exception(strError);
    }
  }

  static Future<bool> updateStatTech(String idTech, bool valid) async {
    try {
      

          final response = await put(Uri.parse("$serverUrl/tech/updateStatTech"),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'_id': idTech, 'valid': valid}));
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
}
