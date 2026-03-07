import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/transaction_model.dart';
import '../../../services/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return InMemoryTransactionRepository();
});

class TransactionsNotifier extends StateNotifier<List<SpendlyTransaction>> {
  TransactionsNotifier(this._repository) : super(_repository.fetchTransactions());

  final TransactionRepository _repository;

  Future<void> addTransaction(SpendlyTransaction transaction) async {
    await _repository.saveTransaction(transaction);
    state = _repository.fetchTransactions();
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<SpendlyTransaction>>((ref) {
  return TransactionsNotifier(ref.read(transactionRepositoryProvider));
});

final currencyProvider = StateProvider<String>((ref) => 'INR');
final monthlyBudgetProvider = StateProvider<double>((ref) => 2000);
final darkModeProvider = StateProvider<bool>((ref) => false);
final monthFilterProvider = StateProvider<String>((ref) => 'This Month');
final expenseEntryCountProvider = StateProvider<int>((ref) => 0);

final filteredTransactionsProvider = Provider<List<SpendlyTransaction>>((ref) {
  final filter = ref.watch(monthFilterProvider);
  final all = ref.watch(transactionsProvider);
  final now = DateTime.now();

  return all.where((tx) {
    if (tx.type != TransactionType.expense) {
      return false;
    }

    if (filter == 'Last 3 Months') {
      final threshold = DateTime(now.year, now.month - 2, 1);
      return !tx.date.isBefore(threshold);
    }

    return tx.date.year == now.year && tx.date.month == now.month;
  }).toList();
});
