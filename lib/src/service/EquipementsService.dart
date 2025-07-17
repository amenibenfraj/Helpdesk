import 'dart:convert';

import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/Equipement.dart';
import 'package:http/http.dart';

class Equipementsservice {
  static Future<bool> assignEquipmentUser({
    required String equipmentId,
    required String userId,
    required String role,
  }) async {
    try {
      final url = Uri.parse('$serverUrl/equipmentHelpdesk/assignEquipmentUser');

      final body = jsonEncode({
        "equipmentId": {"equipment": equipmentId},
        "userId": userId,
        "role": role,
      });

      final headers = {
        'Content-Type': 'application/json',
      };
      final response = await post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        
        return true;
      } else {
        throw Exception(' ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<List<Equipement>?> getListEquipment() async {
    try {
      final response =
          await get(Uri.parse('$serverUrl/equipmentHelpdesk/getAllEquipment'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérifie si 'rows' existe et est bien une liste
        if (data.containsKey('rows') && data['rows'] is List) {
          final List<dynamic> equipementList = data['rows'];

          // Retourner la liste des équipements convertis
          return equipementList
              .map((json) => Equipement.fromJson(json))
              .toList();
        } else {
          throw Exception(
              "La réponse du serveur ne contient pas de liste valide ");
        }
      } else {
        throw Exception(
            'Failed to load technicians with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<bool> deleteEquipementUser(
      String equipmentId, String userId, String role) async {
    final Map<String, dynamic> body = {
      'equipmentId': equipmentId,
      'userId': userId,
      'role': role,
    };

    final response = await post(
      Uri.parse('$serverUrl/equipmentHelpdesk/deleteEquipmentUser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return true;
    }
    print('erreur: ${response.body}');
    return false;
  }

  static Future<Equipement?> editEquipement(
      String id, Equipement newEquip) async {
    try {
      final response = await post(
        Uri.parse('$serverUrl/equipmentHelpdesk/updateEquipmentHelpdesk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "_id": id,
          "data": {
            "serialNumber": newEquip.serialNumber,
            "designation": newEquip.designation,
            "TypeEquipment": newEquip.typeEquipment?.id,
            "version": newEquip.version,
            "barcode": newEquip.barcode
          }
        }),
      );
      if (response.statusCode == 200) {
        return newEquip;
      } else {
        throw Exception('erreur lors de modification');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

static Future<bool> createEquipment(Equipement newEquipment) async {
    try {
      final response = await post(
        Uri.parse('$serverUrl/equipmentHelpdesk/createEquipmentHelpdesk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "data": {
            "serialNumber": newEquipment.serialNumber,
            "designation": newEquipment.designation,
            "version": newEquipment.version,
            "barcode": newEquipment.barcode,
            "assigned": newEquipment.assigned,
            "reference": newEquipment.reference,
            "TypeEquipment": newEquipment.typeEquipment?.toJson(),
          }
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("erreur $e");
      return false;
    }
  }

  
}
