import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/service/socket_service.dart';

import '../helpers/consts.dart';
import '../models/FileModel.dart';
import '../models/Ticket.dart';
import '../models/chatMessage.dart';
import '../service/TicketService.dart';
import '../service/UserService.dart';
import 'user_controller.dart';

class ChatController extends GetxController {
  final storage = FlutterSecureStorage();
  final SocketService socketService = SocketService();
  final UserController userController = Get.find<UserController>();
  var messages = <ChatMessage>[].obs;
  final ScrollController scrollController = ScrollController();
  String currentUserId = '';
  var currentUser = Rx<User?>(null);

  Rx<File?> selectedFile = Rx<File?>(null);
  var fileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserId();
  }

  Future<void> loadUserId() async {
    String? userId = await storage.read(key: USER_ID);
    if (userId != null) {
      currentUserId = userId;
      final user =
          await Userservice.getUser(); // Récupère le user depuis ton API
      if (user != null) {
        setCurrentUser(user); // Met à jour currentUser
      } else {
        print('Échec de récupération de l\'utilisateur');
      }
    } else {
      print("Aucun ID utilisateur trouvé dans le stockage sécurisé");
    }
  }
 static Future<void> preloadMessages(String ticketId, ChatController controller) async {
  try {
    // Vider les anciens messages car reste stocker dans le memoire
    controller.messages.clear();
    
    
  } catch (e) {
    print('Erreur de préchargement des messages: $e');
  }
}
  void setCurrentUser(User user) {
    currentUser.value = user;
  }

  //Parser chaque message JSON en ChatMessage pour simplifier l'affichage
  void loadMessages(List<dynamic> data) {
    messages.clear();
    for (var msg in data) {
      final senderData = msg['sender'];
      if (senderData != null && senderData['id'] != null) {
        final sender = User(    //ou on peut faire User.fromJson pour convertit json en objet dart
          id: senderData['id'],
          firstName: senderData['firstName'] ?? '',
          lastName: senderData['lastName'] ?? '',
          email: senderData['email'] ?? '',
          password: '',
          service: senderData['service'] ?? '',
          authority: senderData['authority'] ?? '',
          image: senderData['image'] != null
              ? FileModel.fromJson(senderData['image'])
              : null,
        );

        messages.add(ChatMessage(   //Parser chaque message JSON en ChatMessage 

          sender: sender,
          message: msg['message'],
          listOfFiles: [],
          createdAt: DateTime.tryParse(msg['createdAt'] ?? ''),
        ));
      }
    }
    messages.refresh(); // Assurer la mise à jour de l'UI
    update();
  }

  // Méthode pour envoyer un message
  void envoyerMessage(String ticketId, String messageText) {
    if (messageText.isNotEmpty) {
      if (currentUser.value == null || currentUser.value!.id.isEmpty) {
        print('Erreur : utilisateur non défini ou ID vide');
        return;
      }

      socketService.sendMessage(
        ticketId,
        currentUser.value!.id,
        messageText,
      );

      messages.add(ChatMessage(
        sender: currentUser.value!,
        message: messageText,
        listOfFiles: [],
      ));
      messages
          .refresh(); // Met à jour l'interface pour afficher le nouveau message
      scrollToBottom();
      update();
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> pickFile() async {
    var result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      selectedFile.value = File(result.files.single.path!);
      fileName.value = result.files.single.name;
      update(); // ou notifyListeners()
      print("Fichier sélectionné : ${selectedFile.value!.path}");
    } else {
      print("Aucun fichier sélectionné");
    }
  }
     Future<Ticket> getTicket(String id) async {
    Ticket ticket = await Ticketservice.getTicketById(id);
    return ticket;
  }
}
