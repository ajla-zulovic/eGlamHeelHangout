import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart'; 

@JsonSerializable()
class User {
  int? userId;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? phoneNumber;
  String? address;
  String? profileImage;
  DateTime? dateOfBirth;


  User({
     this.userId,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.address,
    this.profileImage,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
