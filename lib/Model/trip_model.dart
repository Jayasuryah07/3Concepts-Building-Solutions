// To parse this JSON data, do
//
//     final tripDataModel = tripDataModelFromJson(jsonString);

import 'dart:convert';

TripDataModel tripDataModelFromJson(String str) => TripDataModel.fromJson(json.decode(str));

String tripDataModelToJson(TripDataModel data) => json.encode(data.toJson());

class TripDataModel {
  DateTime? tripsDate;
  String? tripsTime;
  int? tripsFromId;
  int? tripsToId;
  String? tripsKm;
  String? tripsPrice;
  Site? fromsite;
  Site? tosite;

  TripDataModel({
    this.tripsDate,
    this.tripsTime,
    this.tripsFromId,
    this.tripsToId,
    this.tripsKm,
    this.tripsPrice,
    this.fromsite,
    this.tosite,
  });

  TripDataModel copyWith({
    DateTime? tripsDate,
    String? tripsTime,
    int? tripsFromId,
    int? tripsToId,
    String? tripsKm,
    String? tripsPrice,
    Site? fromsite,
    Site? tosite,
  }) =>
      TripDataModel(
        tripsDate: tripsDate ?? this.tripsDate,
        tripsTime: tripsTime ?? this.tripsTime,
        tripsFromId: tripsFromId ?? this.tripsFromId,
        tripsToId: tripsToId ?? this.tripsToId,
        tripsKm: tripsKm ?? this.tripsKm,
        tripsPrice: tripsPrice ?? this.tripsPrice,
        fromsite: fromsite ?? this.fromsite,
        tosite: tosite ?? this.tosite,
      );

  factory TripDataModel.fromJson(Map<String, dynamic> json) => TripDataModel(
    tripsDate: json["trips_date"] == null ? null : DateTime.parse(json["trips_date"]),
    tripsTime: json["trips_time"],
    tripsFromId: json["trips_from_id"],
    tripsToId: json["trips_to_id"],
    tripsKm: json["trips_km"],
    tripsPrice: json["trips_price"],
    fromsite: json["fromsite"] == null ? null : Site.fromJson(json["fromsite"]),
    tosite: json["tosite"] == null ? null : Site.fromJson(json["tosite"]),
  );

  Map<String, dynamic> toJson() => {
    "trips_date": "${tripsDate!.year.toString().padLeft(4, '0')}-${tripsDate!.month.toString().padLeft(2, '0')}-${tripsDate!.day.toString().padLeft(2, '0')}",
    "trips_time": tripsTime,
    "trips_from_id": tripsFromId,
    "trips_to_id": tripsToId,
    "trips_km": tripsKm,
    "trips_price": tripsPrice,
    "fromsite": fromsite?.toJson(),
    "tosite": tosite?.toJson(),
  };
}

class Site {
  int? id;
  String? siteName;

  Site({
    this.id,
    this.siteName,
  });

  Site copyWith({
    int? id,
    String? siteName,
  }) =>
      Site(
        id: id ?? this.id,
        siteName: siteName ?? this.siteName,
      );

  factory Site.fromJson(Map<String, dynamic> json) => Site(
    id: json["id"],
    siteName: json["site_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "site_name": siteName,
  };
}
