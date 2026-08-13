class IdeaModel {
  final int id;
  final int userId;
  final String userFullName;
  final String title;
  final String category;
  final String benefit;
  final String description;
  final String? documentUrl;
  final String status; // Pending, Approved, Rejected
  final DateTime createdAt;
  final dynamic evaluation;

  IdeaModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.title,
    required this.category,
    required this.benefit,
    required this.description,
    this.documentUrl,
    required this.status,
    required this.createdAt,
    this.evaluation,
  });

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    return IdeaModel(
      id: json['id'],
      userId: json['userId'] ?? 0,
      userFullName: json['userFullName'] ?? 'Bilinmeyen Kullanıcı',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      benefit: json['benefit'] ?? '',
      description: json['description'] ?? '',
      documentUrl: json['documentUrl'],
      status: json['status'] ?? 'Beklemede',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      evaluation: json['evaluation'],
    );
  }
}
