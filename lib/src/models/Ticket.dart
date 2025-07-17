import 'package:helpdesk/src/models/Equipement.dart';
import 'package:helpdesk/src/models/FileModel.dart';
import 'package:helpdesk/src/models/Solution.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/models/client.dart';
import 'package:helpdesk/src/models/technician.dart';

class Ticket {
  String id;
  DateTime creationDate;
  DateTime? finishDate;
  String number;
  String title;
  String typeTicket;
  String description;
  String? niveauEscalade;
  String status;
  DateTime? resolvedDate;
  DateTime? assignedDate;
  DateTime? closedDate;
  String? chat;
  Solution? solution;
  Client? clientId;
  User? helpdeskUser;
  Equipement? equipmentHelpdesk;
  List<Technician>? technicienId;
  List<FileModel>? listOfFiles;

  Ticket({
    required this.id,
    DateTime? creationDate,
    this.finishDate,
    required this.number,
    required this.title,
    required this.typeTicket,
    required this.description,
    this.niveauEscalade,
    this.status = "",
    this.resolvedDate,
    this.assignedDate,
    this.closedDate,
    this.chat,
    this.solution,
    this.clientId,
    this.helpdeskUser,
    this.equipmentHelpdesk,

    List<Technician>? technicienId,
    List<FileModel>? listOfFiles,
  })  : creationDate = creationDate ?? DateTime.now(),
        listOfFiles = listOfFiles ?? [],
        
        technicienId=technicienId??[];
  ///  Convertir un JSON en Ticket
factory Ticket.fromJson(Map<String, dynamic> json) {
  return Ticket(
    id: json['_id'],
    creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : DateTime.now(),
    finishDate: json['finishDate'] != null ? DateTime.parse(json['finishDate']) : null,
    number: json['number'] ?? '',
    title: json['title'] ?? '',
    typeTicket: json['typeTicket'] ?? '',
    description: json['description'] ?? '',
    niveauEscalade: json['niveauEscalade'],
    status: json['status'] ?? "open",
    resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate']) : DateTime.now(),
    assignedDate: json['assignedDate'] != null ? DateTime.parse(json['assignedDate']) : DateTime.now(),
    closedDate: json['closedDate'] != null ? DateTime.parse(json['closedDate']) : DateTime.now(),
    chat: json['chat']??'',
    solution: json['solution'] != null ? Solution.fromJson(json['solution']) : null,
    clientId: json['clientId'] != null ? Client.fromJson(json['clientId']) : null,
     helpdeskUser: json['helpdeskUser'] != null ? User.fromJson(json['helpdeskUser']) : null,
    equipmentHelpdesk: json['equipmentHelpdesk'] != null
        ? Equipement.fromJson(json['equipmentHelpdesk'])
        : null,
    technicienId: (json['technicienId'] as List?)?.map((item) {
      return Technician.fromJson(item);
    }).toList() ?? [],
    listOfFiles: (json['listOfFiles'] as List?)
        ?.map((file) => FileModel.fromJson(file))
        .toList() ?? [],
  );
}

  //Convertir un Ticket en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id':id,
      'creationDate': creationDate.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'number': number,
      'title': title,
      'typeTicket': typeTicket,
      'description': description,
      'niveauEscalade': niveauEscalade,
      'status': status,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'assignedDate': assignedDate?.toIso8601String(),
      'closedDate': closedDate?.toIso8601String(),
      'chat': chat,
      'solution': solution?.toJson(),
      'clientId': clientId?.toJson(),
      'helpdeskUser': helpdeskUser?.toJson(),
      'equipmentHelpdesk': equipmentHelpdesk?.toJson(),
      'technicienId': technicienId?.map((ele) => ele.toJson()).toList(),
      'listOfFiles': listOfFiles?.map((file) => file.toJson()).toList(),
    };
  }
}