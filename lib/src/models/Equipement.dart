import 'package:helpdesk/src/models/TypeEquipment.dart';

class Equipement {
   String  serialNumber, designation;
  String? id,version, barcode,reference;
   DateTime? inventoryDate;
   bool? assigned;
   TypeEquipment? typeEquipment; // Rendre optionnel

  Equipement({
     this.id,
    required this.serialNumber,
    required this.designation,
     this.barcode,
     this.version,
     this.reference,
     this.inventoryDate,
    this.assigned,
    this.typeEquipment, // Rendre optionnel
  });

  factory Equipement.fromJson(Map<String, dynamic> data) {
  //   print(" TypeEquipment: ${data['TypeEquipment']}");
  // print(" TypeEquipment type: ${data['TypeEquipment'].runtimeType}");
    return Equipement(
      id: data['_id'],
      serialNumber: data["serialNumber"]??'',
      designation: data["designation"]??'',
      barcode: data['barcode']??'',
      reference: data['reference']??'',
      version: data['version']??'',
     inventoryDate: data["inventoryDate"] != null
          ? DateTime.tryParse(data["inventoryDate"]) ?? DateTime.now() //tryParse pour lever l'exception si l input !=date
          : null,
      assigned: data["assigned"] ?? false,
      typeEquipment: data['TypeEquipment'] != null 
        ? TypeEquipment.fromJson(data['TypeEquipment'])
        : null,// Si TypeEquipment est null ou mal formaté, éviter l'erreur
  );
  
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serialNumber': serialNumber,
      'designation': designation,
      'barcode': barcode,
      'reference':reference,
      'version': version,
      'inventoryDate': inventoryDate?.toIso8601String(),
      'assigned': assigned,
      'TypeEquipment': typeEquipment?.toJson(), // Gérer le cas où typeEquipment est null
    };
  }

  @override
  String toString() {
    return 'Equipement(serialNumber: $serialNumber, designation: $designation, '
        'barcode: $barcode, reference:$reference, version: $version, inventoryDate: $inventoryDate, '
        'assigned: $assigned, typeEquipment: $typeEquipment)';
  }
}