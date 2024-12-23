class Transaction {
  final int id;
  final int categoryId;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toString(),
    };
  }
}
