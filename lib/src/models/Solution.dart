import 'package:helpdesk/src/models/FileModel.dart';

class Solution {
  DateTime creationDate;
  String? solution;
  bool valid;
  String? proposedPar;
  List<FileModel>? attachments;

  Solution({
    DateTime? creationDate,
    this.solution,
    this.valid = false,
    this.proposedPar,
    List<FileModel>? attachments,
  })  : creationDate = creationDate ?? DateTime.now(), // Valeur par défaut
        attachments = attachments ?? [];

  ///  Convertir un JSON en Solution
  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'])
          : DateTime.now(), // Défaut si null
      solution: json['solution'],
      valid: json['valid'] ?? false, // Défaut false si null
      proposedPar: json['proposedPar']??'',

      attachments: (json['attachments'] as List?)
              ?.map((file) => FileModel.fromJson(file))
              .toList() ??
          [],
    );
  }

  ///  Convertir une Solution en JSON
  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate.toIso8601String(),
      'solution': solution,
      'valid': valid,
      'proposedPar':proposedPar,
      'attachments': attachments?.map((file) => file.toJson()).toList(),
    };
  }
}
