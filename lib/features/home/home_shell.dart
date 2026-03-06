import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
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
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Add Expense'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final monthFilter = ref.watch(monthFilterProvider);
    final total = transactions.fold<double>(0, (sum, item) => sum + item.amount);

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
              const _AdBadge(),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Current spending', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
          Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spending Trends', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
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
                                if (index < 0 || index >= monthLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(monthLabels[index], style: const TextStyle(color: Colors.blueGrey));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1.2),
                              FlSpot(1, 2.8),
                              FlSpot(2, 1.6),
                              FlSpot(3, 2.3),
                              FlSpot(4, 2.0),
                              FlSpot(5, 1.0),
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
          const SizedBox(height: 22),
          const Text('Recent transactions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...transactions.take(6).map((tx) => _TransactionTile(transaction: tx)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final SpendlyTransaction transaction;

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
          title: Text(transaction.category, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${transaction.note} — ${DateFormat('MMM d, h:mm a').format(transaction.date)}'),
          trailing: Text('-₹${transaction.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
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
          Row(
            children: const [
              Text('Analytics', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
              Spacer(),
              _AdBadge(),
            ],
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
                            PieChartSectionData(value: 1, color: const Color(0xFFCFD7E4), title: ''),
                          ]
                        : grouped.entries.map((entry) {
                            final color = categoryColors[entry.key] ?? const Color(0xFFB7C3D6);
                            return PieChartSectionData(
                              value: entry.value,
                              color: color,
                              title: '',
                              radius: 24,
                            );
                          }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _metricCard('Total monthly spending', '₹${total.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _metricCard('Average daily spending', '₹${avg.toStringAsFixed(2)}'),
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
          child: Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
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
    final transactions = ref.watch(transactionsProvider).where((tx) {
      return tx.date.year == _selected.year &&
          tx.date.month == _selected.month &&
          tx.date.day == _selected.day;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Calendar', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
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
          Text(DateFormat('EEE, MMM d').format(_selected), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          Text('${transactions.length} transactions', style: const TextStyle(color: Colors.blueGrey, fontSize: 18)),
          const SizedBox(height: 10),
          ...transactions.map((tx) => _TransactionTile(transaction: tx)),
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
          const Text('Settings', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
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
                  subtitle: Text(NumberFormat.currency(symbol: currency == 'INR' ? '₹' : '\$').format(budget)),
                  trailing: IconButton(
                    onPressed: () {
                      ref.read(monthlyBudgetProvider.notifier).state = budget + 500;
                    },
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
                const ListTile(title: Text('Export data'), trailing: Icon(Icons.chevron_right)),
                const Divider(height: 1),
                const ListTile(title: Text('About Spendly'), trailing: Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Ad', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
