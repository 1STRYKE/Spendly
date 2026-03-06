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
  final String type;
}
