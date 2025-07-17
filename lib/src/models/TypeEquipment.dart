import 'package:helpdesk/src/models/Problem.dart';

class Logo {
  String id, title, fileName, path;
  DateTime? uploadDate;
  

  Logo({
    required this.id,
    required this.title,
    required this.fileName,
    required this.path,
    this.uploadDate,
   
  });

  factory Logo.fromJson(Map<String, dynamic> data) {
    return Logo(
      id: data['_id']??'',
      title: data['title']??'',
      fileName: data['fileName']??'',
      path: data['path']??'',
      uploadDate: data['uploadDate'] != null ? DateTime.parse(data['uploadDate']) : null,
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'fileName': fileName,
      'path': path,
      'uploadDate': uploadDate.toString(),
    };
  }
}

class TypeEquipment {
   String id,typeName, typeEquip;
List<Problem>? listProblems; 
   Logo? logo;

  TypeEquipment({
    required this.id,
    required this.typeName,
    required this.typeEquip,
     this.listProblems,
    this.logo,
  });

// conversion de json vers objet dart
factory TypeEquipment.fromJson(Map<String, dynamic> data) {
    return TypeEquipment(
      id: data['_id'],
      typeName: data['typeName'] ?? "",  
      typeEquip: data['typeEquip'] ?? "",  
      listProblems: data['listProblems'] != null
          ? List<Problem>.from(data['listProblems'].map((e) =>Problem.fromJson(e))) 
          : [],
       logo: data['logo'] != null ? Logo.fromJson(data['logo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id':id,
      'typeName': typeName,
      'listProblems': listProblems,
      'logo': logo?.toJson(),
    };
  }
}
