// To parse this JSON data, do
//
//     final sitesDataModel = sitesDataModelFromJson(jsonString);

import 'dart:convert';

SitesDataModel sitesDataModelFromJson(String str) => SitesDataModel.fromJson(json.decode(str));

String sitesDataModelToJson(SitesDataModel data) => json.encode(data.toJson());

class SitesDataModel {
  int? id;
  String? siteName;

  SitesDataModel({
    this.id,
    this.siteName,
  });

  SitesDataModel copyWith({
    int? id,
    String? siteName,
  }) =>
      SitesDataModel(
        id: id ?? this.id,
        siteName: siteName ?? this.siteName,
      );

  factory SitesDataModel.fromJson(Map<String, dynamic> json) => SitesDataModel(
    id: json["id"],
    siteName: json["site_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "site_name": siteName,
  };
}
