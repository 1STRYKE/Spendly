import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../transactions/application/transactions_notifier.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _category = spendlyCategories.first;
  DateTime _date = DateTime.now();
  TransactionType _type = TransactionType.expense;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            DropdownButtonFormField<String>(
              value: _category,
              items: spendlyCategories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? spendlyCategories.first),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note')),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_date)),
              trailing: IconButton(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                  );
                  if (selected != null) {
                    setState(() => _date = selected);
                  }
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null) {
                    return;
                  }
                  final tx = SpendlyTransaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: amount,
                    category: _category,
                    date: _date,
                    note: _noteController.text.trim(),
                    type: _type,
                  );
                  await ref.read(transactionsProvider.notifier).addTransaction(tx);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
