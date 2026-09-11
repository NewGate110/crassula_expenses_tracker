class MoneyTransaction {
  final String id;
  final double amount;
  final bool isIncome;
  final String categoryName;
  final int categoryIconCode;
  final String? tag;
  final String comment;
  final DateTime date;

  const MoneyTransaction({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.categoryName,
    required this.categoryIconCode,
    required this.date,
    this.tag,
    this.comment = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'isIncome': isIncome,
      'categoryName': categoryName,
      'categoryIconCode': categoryIconCode,
      'tag': tag,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory MoneyTransaction.fromJson(Map<String, dynamic> json) {
    return MoneyTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['isIncome'] as bool,
      categoryName: json['categoryName'] as String,
      categoryIconCode: json['categoryIconCode'] as int,
      tag: json['tag'] as String?,
      comment: json['comment'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
