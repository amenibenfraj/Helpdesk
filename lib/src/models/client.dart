import 'package:helpdesk/src/models/FileModel.dart';
import 'package:helpdesk/src/models/User.dart';

class Client extends User {
   String id,service;
   String? location;
   bool? status;

  Client({
    this.id = '',
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
    required String authority,
    FileModel? image,
    required this.service,
    required this.location,
     bool? status,
  }) : super(
   
    firstName: firstName,
    lastName: lastName,
    email: email,
    password:password,
    service:service,
    phoneNumber: phoneNumber,
    authority: authority,
    image: image,
    status: status
  );

  // Convertir un JSON en un objet Client
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email']??'',
      password:json['password']??'',
      phoneNumber: json['phoneNumber']??'',
      authority: json['authority'],
      image: json['image'] != null ? FileModel.fromJson(json['image']) : null,
      service: json['service']??'',
      location: json['location']??'',
      status: json['status']??false,
    );
  }

  // Convertir un objet Client en JSON
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'service': service,
      'location': location,
      'status': status,
    });
    return json;
  }

}