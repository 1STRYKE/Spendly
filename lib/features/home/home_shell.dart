import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../services/ad_service.dart';
import '../../widgets/ad_banner.dart';
import '../add_expense/add_expense_screen.dart';
import '../transactions/application/transactions_notifier.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  Future<void> _openAddExpense() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );

    if (created == true) {
      final count = ref.read(expenseEntryCountProvider);
      if (count >= 3) {
        ref.read(expenseEntryCountProvider.notifier).state = 0;
        await AdService.showInterstitialIfReady();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAddExpense();
        setState(() => _index = 0);
      });
    }

    final pages = const [
      DashboardScreen(),
      AnalyticsScreen(),
      SizedBox.shrink(),
      CalendarScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) async {
          setState(() => _index = value);
          if (value == 1) {
            await AdService.showInterstitialIfReady();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add Expense',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final currency = ref.watch(currencyProvider);
    final monthFilter = ref.watch(monthFilterProvider);
    final total = transactions.fold<double>(0, (sum, item) => sum + item.amount);
    final budgetProgress = budget <= 0 ? 0 : (total / budget).clamp(0, 1).toDouble();
    final symbol = _currencySymbol(currency);

    final monthlySpending = _lastSixMonthsSpending(ref.watch(transactionsProvider));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: monthFilter,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                  DropdownMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(monthFilterProvider.notifier).state = value;
                  }
                },
              ),
              const Spacer(),
              Text(
                'Budget ${_formatCurrency(currency, budget)}',
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Current spending',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
          Text(
            _formatCurrency(currency, total),
            style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: budgetProgress, minHeight: 8),
          ),
          if (total > budget)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Budget exceeded by ${_formatCurrency(currency, total - budget)}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending Trends',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: monthlySpending.fold<double>(0, (max, e) => e.amount > max ? e.amount : max) * 1.25 + 1,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= monthlySpending.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  monthlySpending[index].label,
                                  style: const TextStyle(color: Colors.blueGrey),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < monthlySpending.length; i++)
                                FlSpot(i.toDouble(), monthlySpending[i].amount),
                            ],
                            color: Colors.black,
                            barWidth: 4,
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: AdBanner()),
          const SizedBox(height: 16),
          const Text(
            'Recent transactions',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No transactions yet'),
                subtitle: Text('Tap Add Expense to create your first entry.'),
              ),
            ),
          ...transactions.take(6).map(
            (tx) => _TransactionTile(transaction: tx, symbol: symbol),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.symbol});

  final SpendlyTransaction transaction;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFECEFF5),
            child: Text(transaction.category.characters.first),
          ),
          title: Text(
            transaction.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${transaction.note} — ${DateFormat('MMM d, h:mm a').format(transaction.date)}',
          ),
          trailing: Text(
            '-$symbol${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final currency = ref.watch(currencyProvider);
    final total = transactions.fold<double>(0, (sum, item) => sum + item.amount);
    final avg = total / DateTime.now().day;

    final grouped = <String, double>{};
    for (final tx in transactions) {
      grouped[tx.category] = (grouped[tx.category] ?? 0) + tx.amount;
    }

    final top = grouped.entries.isEmpty
        ? 'N/A'
        : grouped.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 55,
                    sections: grouped.entries.isEmpty
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: const Color(0xFFCFD7E4),
                              title: '',
                            ),
                          ]
                        : grouped.entries.map((entry) {
                            final color = _categoryColor(entry.key);
                            final pct = ((entry.value / total) * 100).round();
                            return PieChartSectionData(
                              value: entry.value,
                              color: color,
                              title: '$pct%',
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              radius: 24,
                            );
                          }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: grouped.entries.map((entry) {
              final color = _categoryColor(entry.key);
              final pct = total == 0 ? 0 : ((entry.value / total) * 100).round();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('${entry.key} $pct%'),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Center(child: AdBanner()),
          const SizedBox(height: 12),
          _metricCard('Total monthly spending', _formatCurrency(currency, total)),
          const SizedBox(height: 10),
          _metricCard('Average daily spending', _formatCurrency(currency, avg)),
          const SizedBox(height: 10),
          _metricCard('Top spending category', top),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.blueGrey)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            value,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final symbol = _currencySymbol(currency);
    final transactions = ref.watch(transactionsProvider).where((tx) {
      return tx.date.year == _selected.year &&
          tx.date.month == _selected.month &&
          tx.date.day == _selected.day &&
          tx.type == TransactionType.expense;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final dayTotal = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Calendar',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            child: CalendarDatePicker(
              initialDate: _selected,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onDateChanged: (date) => setState(() => _selected = date),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('EEE, MMM d').format(_selected),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          Text(
            '${transactions.length} transactions • ${_formatCurrency(currency, dayTotal)}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 18),
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No expenses for this date'),
              ),
            ),
          ...transactions.map((tx) => _TransactionTile(transaction: tx, symbol: symbol)),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final budget = ref.watch(monthlyBudgetProvider);
    final darkMode = ref.watch(darkModeProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(currency == 'INR' ? 'INR (₹)' : 'USD (\$)'),
                  trailing: DropdownButton<String>(
                    value: currency,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(currencyProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Monthly budget'),
                  subtitle: Text(_formatCurrency(currency, budget)),
                  trailing: IconButton(
                    onPressed: () => _showBudgetEditDialog(context, ref, budget),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: darkMode,
                  onChanged: (value) => ref.read(darkModeProvider.notifier).state = value,
                  title: const Text('Dark mode'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Export data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final all = ref.read(transactionsProvider);
                    final csv = StringBuffer('id,amount,category,date,note,type\n');
                    for (final tx in all) {
                      csv.writeln(
                        '${tx.id},${tx.amount},${tx.category},'
                        '${tx.date.toIso8601String()},${tx.note},${tx.type.name}',
                      );
                    }
                    await Clipboard.setData(ClipboardData(text: csv.toString()));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Export copied (${all.length} rows) to clipboard.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About Spendly'),
                  subtitle: const Text('Track money simply'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Spendly',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text('Minimal expense tracker focused on fast manual tracking.'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBudgetEditDialog(
    BuildContext context,
    WidgetRef ref,
    double initial,
  ) async {
    final controller = TextEditingController(text: initial.toStringAsFixed(0));
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Monthly budget'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Budget amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed > 0) {
                  ref.read(monthlyBudgetProvider.notifier).state = parsed;
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }
}

String _currencySymbol(String currency) => currency == 'USD' ? '\$' : '₹';

String _formatCurrency(String currency, double amount) {
  final symbol = _currencySymbol(currency);
  return NumberFormat.currency(symbol: symbol).format(amount);
}

Color _categoryColor(String category) {
  switch (category) {
    case 'Food':
      return const Color(0xFF0A0A0A);
    case 'Transport':
      return const Color(0xFF8A99B2);
    case 'Shopping':
      return const Color(0xFFD4DCE7);
    case 'Bills':
      return const Color(0xFF394B70);
    case 'Entertainment':
      return const Color(0xFFB5C3D8);
    case 'Travel':
      return const Color(0xFF5C6D8A);
    case 'Pet Care':
      return const Color(0xFF90A2BE);
    default:
      return const Color(0xFFC5CEDB);
  }
}

class _MonthlySpend {
  const _MonthlySpend(this.label, this.amount);

  final String label;
  final double amount;
}

List<_MonthlySpend> _lastSixMonthsSpending(List<SpendlyTransaction> transactions) {
  final now = DateTime.now();
  final months = <DateTime>[];
  for (var i = 5; i >= 0; i--) {
    months.add(DateTime(now.year, now.month - i, 1));
  }

  final values = months.map((monthStart) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
    final total = transactions
        .where(
          (tx) =>
              tx.type == TransactionType.expense &&
              !tx.date.isBefore(monthStart) &&
              tx.date.isBefore(monthEnd),
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    return _MonthlySpend(DateFormat('MMM').format(monthStart), total);
  }).toList();

  return values;
}
