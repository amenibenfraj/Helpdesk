import 'dart:convert';

import 'package:helpdesk/src/helpers/consts.dart';
import 'package:helpdesk/src/models/TypeEquipment.dart';
import 'package:http/http.dart';

import '../models/Problem.dart';

class TypeEquipementservice {
  static Future<List<TypeEquipment>> getAllTypes() async {
    try {
      final response =
          await get(Uri.parse('$serverUrl/typeEquipment/getAllTypeEquipment'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List l = data['rows'];
        //chaque element json convertit en objet dart(typeEquipement)
        return l.map((ele) => TypeEquipment.fromJson(ele)).toList();
      } else {
        throw Exception('erreur lors du chargement des types d\'équipement ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(' echec de la récupération  : $e');
    }
  }

  static Future<List<Problem?>> fetchTypeProblems(String idType)async{
    try{
      Response response=await get(Uri.parse('$serverUrl/typeEquipment/getTypeEquipmentById/$idType'));
      print('REPONSE APRES ENVOI ${response.body}');
      if(response.statusCode==200){
        Map<String,dynamic> data=jsonDecode(response.body);
        List jsonListProblems = data['listProblems'];
        List<Problem?> lProblems=jsonListProblems.map((ele)=>Problem.fromJson(ele)).toList();
        return lProblems;
      }else{
        Map<String,dynamic> data=jsonDecode(response.body);
        throw Exception('ERREUR : $data[\'message\']');

      }
    }catch(e){
        throw Exception('ERREUR LORS DE LA RECUPERATION DES PROBLEMES : $e');
    }
  }

  static Future<bool> addProblemToType(String typeEquipId,Problem problem)async{
    try {
      Response response=await post(Uri.parse('$serverUrl/problem/createProblem'),
                                headers: {'Content-Type':'application/json'},
                                body: jsonEncode({
                                  "nomProblem": problem.nomProblem,
                                  "description": problem.description,
                                  "typeEquipmentId": typeEquipId,
                                }),
      );
      if(response.statusCode==200){
        return true;
      }else{
        Map<String,dynamic> api =jsonDecode(response.body);
        print('Erreur lors de l\'ajout d\'un probleme $api[\'message\']');
        return false;
      }
    } catch (e) {
        throw Exception('Erreur ajout probleme : $e');
    }

  }

static Future<bool> deleteProblem(String idProblem)async{
  try {
    Response response=await post(Uri.parse('$serverUrl/problem/deleteProblem'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({ "_id":idProblem,})
      );

      if(response.statusCode==200){
        return true;
      }else{
        Map<String,dynamic> api =jsonDecode(response.body);
        print('Erreur lors de la suppression d\'un probleme $api[\'message\']');
        return false;
      }
    } catch (e) {
      throw Exception('Erreur suppression probleme $e');
    }
  }
  static Future<bool> updateProblem(Problem updatedProblem)async{
    try {
      Response response=await put(Uri.parse('$serverUrl/problem/updateProblem'),
          headers: {'Content-Type':'application/json'},
          body: jsonEncode({
            "_id":updatedProblem.id,
            "nomProblem":updatedProblem.nomProblem,
            "description":updatedProblem.description
          })
      );
      if(response.statusCode==200){
        return true;
      }else{
        Map<String,dynamic> api =jsonDecode(response.body);
        print('Erreur lors de la mise à jour d\'un probleme $api[\'message\']');
        return false;
      }
    } catch (e) {
      print('Erreur maj probleme $e');
      throw Exception('Erreur maj probleme $e');
    }
  }
}
