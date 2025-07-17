class NotificationModel {
   String id;
   String message;
   String type; 
   String ticketId;  
   bool read;
   String? createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.ticketId, 
    required this.read,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      ticketId: json['ticketId'] ?? '',  
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'type': type,
      'ticketId': ticketId,  
      'read': read,
      'createdAt': createdAt,
    };
  }
}
