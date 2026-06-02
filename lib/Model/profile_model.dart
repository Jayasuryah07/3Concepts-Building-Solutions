// To parse this JSON data, do
//
//     final profileDataModel = profileDataModelFromJson(jsonString);

import 'dart:convert';

ProfileDataModel profileDataModelFromJson(String str) => ProfileDataModel.fromJson(json.decode(str));

String profileDataModelToJson(ProfileDataModel data) => json.encode(data.toJson());

class ProfileDataModel {
  int? id;
  String? employeeCode;
  String? name;
  String? mobile;
  String? email;
  String? userPosition;
  String? userImage;

  ProfileDataModel({
    this.id,
    this.employeeCode,
    this.name,
    this.mobile,
    this.email,
    this.userPosition,
    this.userImage,
  });

  ProfileDataModel copyWith({
    int? id,
    String? employeeCode,
    String? name,
    String? mobile,
    String? email,
    String? userPosition,
    String? userImage,
  }) =>
      ProfileDataModel(
        id: id ?? this.id,
        employeeCode: employeeCode ?? this.employeeCode,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        userPosition: userPosition ?? this.userPosition,
        userImage: userImage ?? this.userImage,
      );

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) => ProfileDataModel(
    id: json["id"],
    employeeCode: json["employee_code"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    userPosition: json["user_position"],
    userImage: json["user_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employee_code": employeeCode,
    "name": name,
    "mobile": mobile,
    "email": email,
    "user_position": userPosition,
    "user_image": userImage,
  };
}
