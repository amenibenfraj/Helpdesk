import 'package:helpdesk/src/models/FileModel.dart';

class User {
  String id;
  String firstName;
  String lastName;
  String email,password;
  String service;
  String? phoneNumber, location;
  String authority;
  FileModel? image;
  bool? status,valid;

  
  List<String>? listEquipment;

  User({
    //constructeur nommé
    this.id = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.service,
    this.phoneNumber,
    this.location,
    required this.authority,
    this.image,
    this.status,
    this.valid,
    this.listEquipment,
  });

  // Convertir un JSON (API)en un objet User //communication avec backend
  factory User.fromJson(Map<String, dynamic> data) {
    return User(
        id: data['_id'],
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        password:data['password']??'',
        service: data['service'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        location: data['location'] ?? '',
        authority: data['authority'] ?? '',
        image: data['image'] != null ? FileModel.fromJson(data['image']) : null,
        status: data['status'] ?? false,
        valid:data['valid']??false,
        listEquipment: (data['listEquipment'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],);
  }

  // Convertir un objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password':password,
      'service': service,
      'phoneNumber': phoneNumber,
      'location': location,
      'authority': authority,
      'image': image,
      'status': status,
      'valid':valid,
      'listEquipment': listEquipment?? [],

    };
  }

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, email: $email,password:$password, service: $service, phoneNumber: $phoneNumber, authority: $authority, status: $status}';
  }
}
