class Category {
  final int id;
  final String name;
  final bool isIncome;

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      isIncome: json['is_income'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_income': isIncome,
    };
  }
}
