// To parse this JSON data, do
//
//     final userDataModel = userDataModelFromJson(jsonString);

import 'dart:convert';

UserDataModel userDataModelFromJson(String str) => UserDataModel.fromJson(json.decode(str));

String userDataModelToJson(UserDataModel data) => json.encode(data.toJson());

class UserDataModel {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? employeeCode;
  String? employeeSalary;
  int? userType;
  String? userPosition;
  String? userImage;
  dynamic emailVerifiedAt;
  String? cpassword;
  String? token;
  String? deviceId;
  int? loggedIn;
  DateTime? lastLogin;
  String? status;
  dynamic remarks;
  DateTime? createdAt;
  dynamic createdBy;
  DateTime? updatedAt;
  String? updatedBy;

  UserDataModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.employeeCode,
    this.employeeSalary,
    this.userType,
    this.userPosition,
    this.userImage,
    this.emailVerifiedAt,
    this.cpassword,
    this.token,
    this.deviceId,
    this.loggedIn,
    this.lastLogin,
    this.status,
    this.remarks,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  UserDataModel copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    String? employeeCode,
    String? employeeSalary,
    int? userType,
    String? userPosition,
    String? userImage,
    dynamic emailVerifiedAt,
    String? cpassword,
    String? token,
    String? deviceId,
    int? loggedIn,
    DateTime? lastLogin,
    String? status,
    dynamic remarks,
    DateTime? createdAt,
    dynamic createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      UserDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        employeeCode: employeeCode ?? this.employeeCode,
        employeeSalary: employeeSalary ?? this.employeeSalary,
        userType: userType ?? this.userType,
        userPosition: userPosition ?? this.userPosition,
        userImage: userImage ?? this.userImage,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        cpassword: cpassword ?? this.cpassword,
        token: token ?? this.token,
        deviceId: deviceId ?? this.deviceId,
        loggedIn: loggedIn ?? this.loggedIn,
        lastLogin: lastLogin ?? this.lastLogin,
        status: status ?? this.status,
        remarks: remarks ?? this.remarks,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );

  factory UserDataModel.fromJson(Map<String, dynamic> json) => UserDataModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    employeeCode: json["employee_code"],
    employeeSalary: json["employee_salary"],
    userType: json["user_type"],
    userPosition: json["user_position"],
    userImage: json["user_image"],
    emailVerifiedAt: json["email_verified_at"],
    cpassword: json["cpassword"],
    token: json["token"],
    deviceId: json["device_id"],
    loggedIn: json["logged_in"],
    lastLogin: json["last_login"] == null ? null : DateTime.parse(json["last_login"]),
    status: json["status"],
    remarks: json["remarks"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    createdBy: json["created_by"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    updatedBy: json["updated_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "employee_code": employeeCode,
    "employee_salary": employeeSalary,
    "user_type": userType,
    "user_position": userPosition,
    "user_image": userImage,
    "email_verified_at": emailVerifiedAt,
    "cpassword": cpassword,
    "token": token,
    "device_id": deviceId,
    "logged_in": loggedIn,
    "last_login": "${lastLogin!.year.toString().padLeft(4, '0')}-${lastLogin!.month.toString().padLeft(2, '0')}-${lastLogin!.day.toString().padLeft(2, '0')}",
    "status": status,
    "remarks": remarks,
    "created_at": createdAt?.toIso8601String(),
    "created_by": createdBy,
    "updated_at": updatedAt?.toIso8601String(),
    "updated_by": updatedBy,
  };
}
