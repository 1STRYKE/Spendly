import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/transaction_model.dart';

void main() {
  runApp(const SpendlyApp());
}

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A1738)),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 24),
              const Text('Spendly', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Track money simply',
                style: TextStyle(fontSize: 28, color: Colors.blueGrey.shade500),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final List<SpendlyTransaction> _transactions = [
    SpendlyTransaction(
      id: '1', amount: 179.99, category: 'Pet Care', date: DateTime.now(), note: 'Dog grooming', type: 'expense'),
    SpendlyTransaction(
      id: '2', amount: 8.95, category: 'Coffee', date: DateTime.now().subtract(const Duration(days: 1)), note: 'Latte', type: 'expense'),
    SpendlyTransaction(
      id: '3', amount: 75.00, category: 'House Repair', date: DateTime.now().subtract(const Duration(days: 2)), note: 'Fix leak', type: 'expense'),
  ];

  void _addTransaction(SpendlyTransaction transaction) {
    setState(() => _transactions.insert(0, transaction));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(transactions: _transactions),
      AnalyticsScreen(transactions: _transactions),
      CalendarScreen(transactions: _transactions),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          final created = await Navigator.push<SpendlyTransaction>(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (created != null) {
            _addTransaction(created);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.transactions});

  final List<SpendlyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold<double>(0, (sum, item) => sum + item.amount);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('This Month', style: TextStyle(color: Colors.blueGrey, fontSize: 18)),
          const SizedBox(height: 8),
          Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('Spending Trends (Line Chart Placeholder)')),
          ),
          const SizedBox(height: 22),
          const Text('Recent Transactions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...transactions.map(
            (tx) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.category)),
                title: Text(tx.category),
                subtitle: Text(DateFormat('MMM d, h:mm a').format(tx.date)),
                trailing: Text('-₹${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food';
  DateTime _date = DateTime.now();

  final categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Travel',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            DropdownButtonFormField<String>(
              value: _category,
              items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => _category = value ?? 'Food'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 16),
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
                  if (selected != null) setState(() => _date = selected);
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null) return;
                  Navigator.pop(
                    context,
                    SpendlyTransaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      amount: amount,
                      category: _category,
                      date: _date,
                      note: _noteController.text.trim(),
                      type: 'expense',
                    ),
                  );
                },
                child: const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.transactions});

  final List<SpendlyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold<double>(0, (sum, item) => sum + item.amount);
    final avg = transactions.isEmpty ? 0 : total / DateTime.now().day;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Category Distribution', style: TextStyle(fontSize: 34, color: Colors.blueGrey)),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('Pie Chart Placeholder')),
          ),
          const SizedBox(height: 16),
          _metricCard('Total monthly spending', '₹${total.toStringAsFixed(2)}'),
          _metricCard('Average daily spending', '₹${avg.toStringAsFixed(2)}'),
          _metricCard('Top spending category', transactions.isEmpty ? 'N/A' : transactions.first.category),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(title: Text(title), subtitle: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.transactions});

  final List<SpendlyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Calendar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            onDateChanged: (_) {},
          ),
          const SizedBox(height: 10),
          ...transactions.take(3).map(
            (tx) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                title: Text(tx.category),
                subtitle: Text(tx.note),
                trailing: Text('₹${tx.amount.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const ListTile(title: Text('Currency'), subtitle: Text('INR (₹)'), trailing: Icon(Icons.chevron_right)),
                const Divider(height: 1),
                const ListTile(title: Text('Monthly budget'), subtitle: Text('₹2,000'), trailing: Icon(Icons.chevron_right)),
                const Divider(height: 1),
                SwitchListTile(
                  value: darkMode,
                  onChanged: (value) => setState(() => darkMode = value),
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
