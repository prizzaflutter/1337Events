class FeedBackModel{
  String? id;
  String? userId;
  String? login;
  String? comment;
  double rating = 0.0; // Assuming rating is a double, you can adjust as needed
  DateTime? createdAt;

  FeedBackModel({
     this.login,
    this.id,
    this.userId,
    this.rating = 0.0, // Default rating value
    this.comment,
    this.createdAt,
  });

  FeedBackModel.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    id = json['id'];
    rating = (json['rating'] is num) ? json['rating'].toDouble() : 0.0; // Ensure rating is a double
    userId = json['userId'];
    comment = json['feedbackText'];
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'id': id,
      'rating': rating,
      'userId': userId,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}