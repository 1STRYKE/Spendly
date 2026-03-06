# Spendly

Spendly is a Flutter expense tracker prototype built from the PRD: **Track money simply**.

## What is implemented

- Onboarding flow with Spendly brand and CTA.
- Dashboard with current spend, month filter, trend line chart, and recent transactions.
- Add Expense screen with amount, category, date, note, and expense/income toggle.
- Analytics screen with category pie chart and key metrics:
  - total monthly spending
  - average daily spending
  - top category
- Calendar view where selecting a day filters transactions for that date.
- Settings for currency, monthly budget, dark mode, export, and about.
- Ad slots represented in Dashboard and Analytics UIs.

## Architecture and stack

- Flutter + Dart
- Riverpod state management
- Layered setup with:
  - Presentation (`features/...`)
  - Business logic (`features/transactions/application`)
  - Data (`services/transaction_repository.dart`)
- Data model in `models/transaction_model.dart`
- Charting via `fl_chart`
- Ad SDK initialization via `google_mobile_ads`
- Prepared dependencies for Hive persistence integration
