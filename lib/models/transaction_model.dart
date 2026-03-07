enum TransactionType { expense, income }

class SpendlyTransaction {
  const SpendlyTransaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.type,
  });

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final TransactionType type;

  SpendlyTransaction copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    TransactionType? type,
  }) {
    return SpendlyTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }
}

class SpendlyCategory {
  const SpendlyCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final String icon;
}
