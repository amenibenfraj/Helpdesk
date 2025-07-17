import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helpers/consts.dart';
import '../../models/User.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final User? sender;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = sender?.image?.fileName != null
        ? "$serverUrl/uploads/${sender!.image!.fileName}"
        : null;
    print("Raw sender data: $sender");
    print("sender image: ${sender?.image}");
    print("sender image path: ${sender?.image?.path}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              DateFormat('HH:mm').format(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : const AssetImage("assets/images/useravatar.png") as ImageProvider,

                    ),
                    const SizedBox(width: 4),
                    Text("${sender?.firstName} ${sender?.lastName}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              SizedBox(width: 15),
              // Bulle du message
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              if (isMe)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : const AssetImage("assets/images/useravatar.png")
                              as ImageProvider,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
