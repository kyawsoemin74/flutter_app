// To parse this JSON data, do
//
//     final setting = settingFromJson(jsonString);

import 'dart:convert';

Setting settingFromJson(String str) => Setting.fromJson(json.decode(str));

String settingToJson(Setting data) => json.encode(data.toJson());

class Setting {
    Setting({
        this.security,
        this.privacyPolicy,
        this.about,
        this.help,
        this.faq,
    });

    About? security;
    About? privacyPolicy;
    About? about;
    List<About>? help;
    List<About>? faq;

    factory Setting.fromJson(Map<String, dynamic> json) => Setting(
        security: About.fromJson(json["security"]),
        privacyPolicy: About.fromJson(json["privacy_policy"]),
        about: About.fromJson(json["about"]),
        help: List<About>.from(json["help"].map((x) => About.fromJson(x))),
        faq: List<About>.from(json["faq"].map((x) => About.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "security": security!.toJson(),
        "privacy_policy": privacyPolicy!.toJson(),
        "about": about!.toJson(),
        "help": List<dynamic>.from(help!.map((x) => x.toJson())),
        "faq": List<dynamic>.from(faq!.map((x) => x.toJson())),
    };
}

class About {
    About({
        this.title,
        this.content,
    });

    String ?title;
    String? content;

    factory About.fromJson(Map<String, dynamic> json) => About(
        title: json["title"],
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
    };
}
