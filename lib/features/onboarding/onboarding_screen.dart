import 'package:flutter/material.dart';

import '../home/home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.account_balance_wallet, 'Spendly', 'Track money simply'),
      (Icons.add_circle_outline, 'Fast entry', 'Log expenses in seconds'),
      (Icons.analytics_outlined, 'Clear insights', 'Understand spending trends quickly'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(item.$1, color: Colors.white, size: 42),
                        ),
                        const SizedBox(height: 24),
                        Text(item.$2, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(item.$3, style: TextStyle(fontSize: 24, color: Colors.blueGrey.shade500)),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: _page == index ? 16 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _page == index ? Colors.black : const Color(0xFFCBD5E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                  child: Text(_page == items.length - 1 ? 'Get Started' : 'Skip', style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
