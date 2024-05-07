// To parse this JSON data, do
//
//     final dataList = dataListFromJson(jsonString);

import 'dart:convert';

DataList dataListFromJson(String str) => DataList.fromJson(json.decode(str));

String dataListToJson(DataList data) => json.encode(data.toJson());

class DataList {
  String? tag;
  int? count;

  DataList({
    this.tag,
    this.count,
  });

  factory DataList.fromJson(Map<String, dynamic> json) => DataList(
        tag: json["Tag"],
        count: json["Count"],
      );

  Map<String, dynamic> toJson() => {
        "Tag": tag,
        "Count": count,
      };
}
