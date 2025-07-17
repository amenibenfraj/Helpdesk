import 'package:helpdesk/src/models/FileModel.dart';
import 'package:helpdesk/src/models/User.dart';

class Technician extends User {
  Technician({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String service,
    required String password,
    String? phoneNumber,
    String? location,
    required String authority,
    bool? valid,
    bool? status,
    FileModel? image,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          service: service,
          phoneNumber: phoneNumber,
          location: location,
          authority: authority,
          image: image,
          valid: valid,
          status: status,
        );
  // Convertir un JSON en un objet Technicien
  factory Technician.fromJson(Map<String, dynamic> data) {
    return Technician(
      id: data['_id'],
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      service: data['service'] ?? '',
      location: data['location'] ?? '',
      phoneNumber: data['phoneNumber'] ?? 'not available',
      authority: data['authority'] ?? '',
      image: data['image'] != null ? FileModel.fromJson(data['image']) : null,
          
      valid: data['valid'] ?? false,
      status: data['status'] ?? false,
    );
  }

  // Convertir un objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'service': service,
      'phoneNumber': phoneNumber,
      'location': location,
      'authority': authority,
      'image': image,
      'valid': valid,
      'status': status
    };
  }
}
