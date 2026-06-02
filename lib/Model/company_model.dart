// To parse this JSON data, do
//
//     final companyDataModel = companyDataModelFromJson(jsonString);

import 'dart:convert';

CompanyDataModel companyDataModelFromJson(String str) => CompanyDataModel.fromJson(json.decode(str));

String companyDataModelToJson(CompanyDataModel data) => json.encode(data.toJson());

class CompanyDataModel {
  String? companyName;
  String? companyEmail;
  String? companyShort;
  dynamic companyGst;
  dynamic companyPanNo;
  String? companyMobileNo;
  String? companyLogo;
  String? companyAddress;
  String? companyPlace;

  CompanyDataModel({
    this.companyName,
    this.companyEmail,
    this.companyShort,
    this.companyGst,
    this.companyPanNo,
    this.companyMobileNo,
    this.companyLogo,
    this.companyAddress,
    this.companyPlace,
  });

  CompanyDataModel copyWith({
    String? companyName,
    String? companyEmail,
    String? companyShort,
    dynamic companyGst,
    dynamic companyPanNo,
    String? companyMobileNo,
    String? companyLogo,
    String? companyAddress,
    String? companyPlace,
  }) =>
      CompanyDataModel(
        companyName: companyName ?? this.companyName,
        companyEmail: companyEmail ?? this.companyEmail,
        companyShort: companyShort ?? this.companyShort,
        companyGst: companyGst ?? this.companyGst,
        companyPanNo: companyPanNo ?? this.companyPanNo,
        companyMobileNo: companyMobileNo ?? this.companyMobileNo,
        companyLogo: companyLogo ?? this.companyLogo,
        companyAddress: companyAddress ?? this.companyAddress,
        companyPlace: companyPlace ?? this.companyPlace,
      );

  factory CompanyDataModel.fromJson(Map<String, dynamic> json) => CompanyDataModel(
    companyName: json["company_name"],
    companyEmail: json["company_email"],
    companyShort: json["company_short"],
    companyGst: json["company_gst"],
    companyPanNo: json["company_pan_no"],
    companyMobileNo: json["company_mobile_no"],
    companyLogo: json["company_logo"],
    companyAddress: json["company_address"],
    companyPlace: json["company_place"],
  );

  Map<String, dynamic> toJson() => {
    "company_name": companyName,
    "company_email": companyEmail,
    "company_short": companyShort,
    "company_gst": companyGst,
    "company_pan_no": companyPanNo,
    "company_mobile_no": companyMobileNo,
    "company_logo": companyLogo,
    "company_address": companyAddress,
    "company_place": companyPlace,
  };
}
