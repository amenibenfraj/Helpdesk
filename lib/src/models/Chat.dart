import 'package:helpdesk/src/models/chatMessage.dart';

class Chat {
  List<ChatMessage> messages;

  Chat({List<ChatMessage>? messages}) : messages = messages ?? [];

  /// Convertir un JSON en Chat
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      messages: (json['messages'] as List?)
          ?.map((msg) => ChatMessage.fromJson(msg))
          .toList() ??
          [],
    );
  }

  /// Convertir un Chat en JSON
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }
}