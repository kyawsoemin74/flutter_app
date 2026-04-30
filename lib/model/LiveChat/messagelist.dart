// To parse this JSON data, do
//
//     final messagelist = messagelistFromJson(jsonString);

import 'dart:convert';

List<Messagelist> messagelistFromJson(String str) => List<Messagelist>.from(
    json.decode(str).map((x) => Messagelist.fromJson(x)));

String messagelistToJson(List<Messagelist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Messagelist {
  String? name;
  String? uuid;
  String? msg;
  int? matchid;
  int? roomid;
  int? time;
  String? id;
  DateTime? date;
  int? msgtype;

  Messagelist({
    this.name,
    this.uuid,
    this.msg,
    this.matchid,
    this.roomid,
    this.time,
    this.id,
    this.date,
    this.msgtype,
  });

  factory Messagelist.fromJson(Map<String, dynamic> json) => Messagelist(
        name: json["name"],
        uuid: json["uuid"],
        msg: json["msg"],
        matchid: json["matchid"],
        roomid: json["roomid"],
        time: json["time"],
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        msgtype: json["msgtype"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "uuid": uuid,
        "msg": msg,
        "matchid": matchid,
        "roomid": roomid,
        "time": time,
        "_id": id,
        "date": date?.toIso8601String(),
        "msgtype": msgtype,
      };
}
