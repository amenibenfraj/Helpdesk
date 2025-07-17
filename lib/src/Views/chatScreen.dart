import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/chat_controller.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';
import 'package:helpdesk/src/controllers/ticket_controller.dart';
import 'package:helpdesk/src/models/User.dart';
import 'package:helpdesk/src/models/chatMessage.dart';
import 'package:helpdesk/src/service/TicketService.dart';
import 'package:helpdesk/src/service/UserService.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/user_controller.dart';
import '../models/Ticket.dart';
import '../service/socket_service.dart';
import 'Widget/bubbleMessage.dart';

// Nouveau controller dédié pour ChatScreen
class ChatScreenController extends GetxController {
  final SocketService socketService = Get.find<SocketService>();
  final UserController userController = Get.find<UserController>();
  final ChatController chatController = Get.find<ChatController>();
  final TicketController ticketController = Get.find<TicketController>();
  final sessionController session = Get.find<sessionController>();

  Rx<Ticket?> currentTicket = Rx<Ticket?>(null);
  RxBool isTechnician = false.obs;
  RxBool isAdmin = false.obs;
  RxBool isClient = false.obs;
  late User currentUser;
  final String ticketId;

  ChatScreenController({required this.ticketId});

  @override
  void onInit() {
    super.onInit();
    initChat();
  }

  @override
  void onClose() {
    removeSocketListeners();
    super.onClose();
  }

  Future<void> initChat() async {
    // Charger les messages
    chatController.messages.clear();
    chatController.update();

    // Vérifier le rôle utilisateur
    await _updateUserRole();

    try {
      final user = await Userservice.getUser();

      if (user != null) {
        currentUser = user;
        chatController.setCurrentUser(user);
      } else {
        currentUser = User(
          id: userController.userId.value,
          firstName: 'Vous',
          lastName: '',
          email: '',
          password: '',
          service: '',
          authority: '',
        );
        chatController.setCurrentUser(currentUser);
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
      currentUser = User(
        id: userController.userId.value,
        firstName: 'Vous',
        lastName: '',
        email: '',
        password: '',
        service: '',
        authority: '',
      );
      chatController.setCurrentUser(currentUser);
    }

    try {
      final fetchedTicket = await Ticketservice.getTicketById(ticketId);
      print("Ticket récupéré: ${fetchedTicket.status}");
      currentTicket.value = fetchedTicket;
    } catch (e) {
      print('Erreur lors de la récupération du ticket: $e');
    }

    // Rejoindre la salle de chat pour récupérer les messages
    socketService.joinChatRoom(ticketId);

    // Supprimer les anciens écouteurs et configurer les nouveaux
    removeSocketListeners();
    setupSocketListeners(); //Réinitialisation : attache des nouveaux écouteurs propres
  }

  // Fonction pour mettre à jour les rôles de l'utilisateur
  Future<void> _updateUserRole() async {
    String? role = await session.readRole();
    isTechnician.value = role == 'technician';
    isAdmin.value = role == 'admin';
    isClient.value = role == 'client';
    print("Rôle utilisateur: $role (isAdmin: ${isAdmin.value})");
  }

  void removeSocketListeners() {
    socketService.socket.off('newMessage');
    socketService.socket.off('loadMessages');
    socketService.socket.off('error');
  }

  void setupSocketListeners() {
    socketService.socket.on('newMessage', (data) {
      if (data['sender'] != null &&
          data['sender']['id'] != userController.userId.value) {
        chatController.messages.add(ChatMessage(
          sender: currentUser,
          message: data['message'],
          listOfFiles: [],
          createdAt: DateTime.tryParse(data['createdAt'] ?? ''),
        ));
        chatController.update();
      }
    });

    socketService.socket.on('loadMessages', (data) {
      chatController.messages.clear();
      chatController.loadMessages(data);
      chatController.update();
    });

    socketService.socket.on('error', (data) {
      print('Erreur socket: $data');
      Get.snackbar('Erreur', data['message'] ?? 'Une erreur est survenue');
    });
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      socketService.sendMessage(
          ticketId, userController.userId.value, message);

      chatController.messages.add(ChatMessage(
          sender: currentUser, message: message, listOfFiles: []));
      chatController.update();
    }
  }

  Future<bool> saveSolution(String solution, List<File> files) async {
    return await Ticketservice.saveSolution(
      ticketId: ticketId,
      solution: solution,
      files: files,
    );
  }

  Future<bool> validateSolution() async {
    return await Ticketservice.validateSolution(currentTicket.value!.id);
  }
}

// Widget pour l'écran de chat qui utilise le controller
class ChatScreen extends StatelessWidget {
  final String ticketId;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController solutionController = TextEditingController();

  ChatScreen({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    // Initialiser le controller avec GetX
    final controller = Get.put(ChatScreenController(ticketId: ticketId));
    final chatController = Get.find<ChatController>();
    final ticketController = Get.find<TicketController>();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Partie solution (visible seulement pour technicien)
          Obx(() => controller.isTechnician.value
              ? Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, -2),
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Solution : ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: solutionController,
                        decoration: InputDecoration(
                          hintText: "Décrivez votre solution ici...",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: ticketController.pickFile,
                            child: Text("Choisir un fichier"),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  List<File> files = ticketController
                                      .selectedFilePaths
                                      .map((path) => File(path))
                                      .toList();

                                  bool success =
                                      await controller.saveSolution(
                                    solutionController.text,
                                    files,
                                  );

                                  if (success) {
                                    Get.snackbar("Succès",
                                        "Solution envoyée avec succès");
                                  } else {
                                    Get.snackbar("Échec",
                                        "Échec de l'envoi de la solution");
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "Envoyer",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(() => chatController.fileName.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  "Fichier: ${chatController.fileName.value}"),
                            )
                          : SizedBox()),
                    ],
                  ),
                )
              : SizedBox.shrink()),

          // Affichage de la solution ou d'un message indiquant aucune solution
          Obx(() => controller.currentTicket.value == null
              ? Center(child: Text(""))
              : (controller.currentTicket.value?.solution != null &&
                      controller.currentTicket.value?.solution!.solution != null)
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Solution proposée :",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(controller.currentTicket.value!.solution!.solution!),
                          const SizedBox(height: 10),

                          if (controller.currentTicket.value!.solution!.valid)
                            Text(
                              "Validée",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),

                          // FICHIERS JOINTS
                          if (controller.currentTicket.value!.solution!.attachments !=
                                  null &&
                              controller.currentTicket.value!.solution!.attachments!
                                  .isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  "Fichiers joints :",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...controller.currentTicket.value!.solution!.attachments!
                                    .map((file) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final Uri url =
                                            Uri.parse(file.path);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          Get.snackbar("Erreur",
                                              "Impossible d'ouvrir le fichier.");
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.attach_file,
                                              size: 20,
                                              color: Colors.blueGrey),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "${file.title} (${file.fileName})",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),

                          // BOUTON POUR LE CLIENT SI LE TICKET EST RESOLU
                          Obx(() => (controller.isClient.value || controller.isTechnician.value) &&
                                  controller.currentTicket.value!.status == 'Resolved'
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      bool success = await controller.validateSolution();
                                      Get.back();
                                      Get.snackbar(
                                        success ? "Succès" : "Erreur",
                                        success
                                            ? "Solution validée"
                                            : "Échec de validation",
                                        backgroundColor: success
                                            ? const Color(0xFF00C48C)
                                            : const Color(0xFFFF6B6B),
                                        colorText: Colors.white,
                                        margin: const EdgeInsets.all(12),
                                        duration: const Duration(seconds: 2),
                                        borderRadius: 10,
                                        icon: Icon(
                                          success
                                              ? Icons.check_circle
                                              : Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.check_circle_outline,
                                        color: Colors.white),
                                    label: Text("Valider",
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 62, 102, 153),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink()),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Aucune solution n'a encore été proposée"),
                    )),

          // Partie discussion
          Expanded(
            child: Obx(() {
              return chatController.messages.isEmpty
                  ? Center(child: Text(""))
                  : ListView.builder(
                      controller: chatController.scrollController,
                      itemCount: chatController.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatController.messages[index];
                        final isMe = message.sender.id ==
                            chatController.currentUser.value?.id;

                        return MessageBubble(
                          message: message.message,
                          isMe: isMe,
                          sender: message.sender,
                          timestamp: message.createdAt ?? DateTime.now(),
                        );
                      },
                    );
            }),
          ),
          
Obx(() {
  
  bool showMessageBox = controller.currentTicket.value != null &&
      !controller.isAdmin.value;
      
  print("Afficher zone message: $showMessageBox, Admin: ${controller.isAdmin.value}, Status: ${controller.currentTicket.value?.status}");
      
  return showMessageBox
      ? Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -2),
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: "Écrire un message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    controller.sendMessage(messageController.text);
                    messageController.clear();
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  controller.sendMessage(messageController.text);
                  messageController.clear();
                },
              ),
            ),
          ],
        )
      : SizedBox.shrink();
})        ],
      ),
    );
  }
}