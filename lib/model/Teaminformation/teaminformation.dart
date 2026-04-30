class Teaminformation {
  Team? team;
  Venue? venue;

  Teaminformation({this.team, this.venue});

  Teaminformation.fromJson(Map<String, dynamic> json) {
    team = json['team'] != null ? new Team.fromJson(json['team']) : null;
    venue = json['venue'] != null ? new Venue.fromJson(json['venue']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.team != null) {
      data['team'] = this.team!.toJson();
    }
    if (this.venue != null) {
      data['venue'] = this.venue!.toJson();
    }
    return data;
  }
}

class Team {
  int? id;
  String? name;
  String? code;
  String? country;
  int? founded;
  bool? national;
  String? logo;

  Team(
      {this.id,
      this.name,
      this.code,
      this.country,
      this.founded,
      this.national,
      this.logo});

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    country = json['country'];
    founded = json['founded'];
    national = json['national'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['country'] = this.country;
    data['founded'] = this.founded;
    data['national'] = this.national;
    data['logo'] = this.logo;
    return data;
  }
}

class Venue {
  int? id;
  String? name;
  String? address;
  String? city;
  int? capacity;
  String? surface;
  String? image;

  Venue(
      {this.id,
      this.name,
      this.address,
      this.city,
      this.capacity,
      this.surface,
      this.image});

  Venue.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    city = json['city'];
    capacity = json['capacity'];
    surface = json['surface'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['city'] = this.city;
    data['capacity'] = this.capacity;
    data['surface'] = this.surface;
    data['image'] = this.image;
    return data;
  }
}