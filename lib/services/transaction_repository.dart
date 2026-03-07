import '../models/transaction_model.dart';

abstract class TransactionRepository {
  List<SpendlyTransaction> fetchTransactions();
  Future<void> saveTransaction(SpendlyTransaction transaction);
}

class InMemoryTransactionRepository implements TransactionRepository {
  final List<SpendlyTransaction> _store = [
    SpendlyTransaction(
      id: '1',
      amount: 179.99,
      category: 'Pet Care',
      date: DateTime.now(),
      note: 'Dog grooming',
      type: TransactionType.expense,
    ),
    SpendlyTransaction(
      id: '2',
      amount: 8.95,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Coffee',
      type: TransactionType.expense,
    ),
    SpendlyTransaction(
      id: '3',
      amount: 75.00,
      category: 'Bills',
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: 'House repair',
      type: TransactionType.expense,
    ),
  ];

  @override
  List<SpendlyTransaction> fetchTransactions() => List.unmodifiable(_store);

  @override
  Future<void> saveTransaction(SpendlyTransaction transaction) async {
    _store.insert(0, transaction);
  }
}
