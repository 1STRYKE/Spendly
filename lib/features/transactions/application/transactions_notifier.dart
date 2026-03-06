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
