import 'package:helpdesk/src/models/FileModel.dart';

class Admin  {
  String id, firstname, lastname, email, password, authority;
  String? phoneNumber;
  FileModel? image;

  Admin({
    required this.id,
    required this.email,
    required this.lastname,
    required this.firstname,
    this.image,
    required this.password,
    this.phoneNumber,
    required this.authority,
  });

  factory Admin.fromJson(Map<String, dynamic> data) {
    return Admin(
        id: data["_id"],
        email: data["email"],
        firstname: data["firstName"],
        lastname: data["lastName"],
        image: data['image'] != null ? FileModel.fromJson(data['image']) : null,
        password: data["password"],
        phoneNumber: data["phoneNumber"],
        authority: data["authority"]);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstname,
      'lastName': lastname,
      'image': image,
      'password': password,
      'phoneNumber': phoneNumber,
      'authority': authority
    };
  }
}
