class NewsModel {
  final String title;
  final String description;
  final String image;
  final String date;

  NewsModel({
    required this.title,
    required this.description,
    required this.image,
    required this.date,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'date': date,
    };
  }
}