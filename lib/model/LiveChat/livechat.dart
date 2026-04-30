// To parse this JSON data, do
//
//     final liveChat = liveChatFromJson(jsonString);

import 'dart:convert';

LiveChat liveChatFromJson(String str) => LiveChat.fromJson(json.decode(str));

String liveChatToJson(LiveChat data) => json.encode(data.toJson());

class LiveChat {
  String? name;
  String? uuid;
  String? msg;
  int? matchid;
  int? roomid;
  int? msgtype;

  LiveChat({
    this.name,
    this.uuid,
    this.msg,
    this.matchid,
    this.roomid,
    this.msgtype
  });

  factory LiveChat.fromJson(Map<String, dynamic> json) => LiveChat(
        name: json["name"],
        uuid: json["uuid"],
        msg: json["msg"],
        matchid: json["matchid"],
        roomid: json["roomid"],
        msgtype: json["msgtype"]
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "uuid": uuid,
        "msg": msg,
        "matchid": matchid,
        "roomid": roomid,
        "msgtype": msgtype
      };
}
