import 'package:helpdesk/src/models/FileModel.dart';
import 'package:helpdesk/src/models/User.dart';

class ChatMessage {
  User sender;
  String message;
  List<FileModel> listOfFiles;
  DateTime? createdAt;

  ChatMessage({
    required this.sender,
    required this.message,
    this.createdAt,
    List<FileModel>? listOfFiles,
  }) : listOfFiles = listOfFiles ?? [];

  // Convertir un JSON en ChatMessage
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: User.fromJson(json['sender']), // Directement récupérer l'objet User
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : null,
      listOfFiles: _parseFilesList(json['listOfFiles']),
    );
  }

  // Méthode utilitaire pour analyser en toute sécurité la liste des fichiers
  static List<FileModel> _parseFilesList(dynamic filesList) {
    if (filesList is List) {
      return filesList
          .map((file) => file is Map<String, dynamic> 
              ? FileModel.fromJson(file) 
              : FileModel(title: '', fileName: '', path: ''))
          .toList();
    }
    return [];
  }

  // Convertir un ChatMessage en JSON
  Map<String, dynamic> toJson() {
    return {
      'sender': sender.toJson(),
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'listOfFiles': listOfFiles.map((file) => file.toJson()).toList(),
    };
  }
}
