import 'package:socket_io_client/socket_io_client.dart' as IO;
//socket_io_client package utilisé pour établir une cnx avec un serveur Socket.IO

class SocketService {
  late IO.Socket socket;

  void connect(String serverUrl) {
    socket = IO.io(serverUrl, <String, dynamic>{ //io est la fonction du package IO , permet de créer une instance de socket
      'transports': [
        'websocket'
      ], // WebSocket est un protocole de communication bidirectionnelle en temps réel
      'autoConnect': false,
    });

    socket.connect(); //Établit la connexion avec le serveur du backend node.js

    socket.onConnect((_) {//écoute la connexion : attendre et réagir
      print("Connecté au serveur Socket.IO");
    });
    // ecoute d'une notification
    socket.on('notification', (data) {
      print(" Notification reçue : $data");
    });

    socket.onDisconnect((_) {
      print("Déconnecté du serveur Socket.IO");
    });

    socket.onError((error) {
      print("Erreur Socket.IO: $error");
    });

    socket.onConnectError((error) {
      print("Erreur de connexion Socket.IO: $error");
    });
  }

  void joinChatRoom(String ticketId) {
    socket.emit("joinChatRoom", ticketId);
  }

  void sendMessage(String ticketId, String senderId, String message) {
    socket.emit("sendMessage", {
      "ticketId": ticketId,
      "senderId": senderId,
      "message": message,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
