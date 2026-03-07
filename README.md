# Spendly

Spendly is a Flutter expense tracker prototype built from the PRD: **Track money simply**.

## Implemented PRD features

- **Onboarding**
  - 3-page onboarding carousel
  - app branding and tagline
  - page indicators and skip/get-started CTA
- **Dashboard**
  - current spending amount
  - month filter (`This Month`, `Last 3 Months`)
  - dynamic line chart from the last six months of expense data
  - monthly budget tracking with progress + over-budget warning
  - recent transactions list + empty state
- **Add Expense**
  - amount, category, date, note
  - expense/income type switch
  - saved entries feed Dashboard/Analytics/Calendar immediately
- **Analytics**
  - category distribution pie chart with percentages
  - category legend with percentages
  - total monthly spending
  - average daily spending
  - top spending category
- **Calendar**
  - monthly date picker
  - selected-date transaction list
  - selected-date totals and count
- **Settings**
  - currency selection (INR / USD)
  - editable monthly budget via dialog
  - dark mode toggle
  - export data (CSV copied to clipboard)
  - about section dialog

## Monetization behavior

- AdMob SDK initialization at app startup.
- Banner ad widgets on Dashboard and Analytics pages.
- Interstitial ad trigger:
  - when opening Analytics
  - after every 3 successful expense entries

## Architecture and stack

- Flutter + Dart
- Riverpod state management
- Layered setup:
  - Presentation (`features/...`)
  - Business logic (`features/transactions/application`)
  - Data (`services/transaction_repository.dart`)
- Data model in `models/transaction_model.dart`
- Charts via `fl_chart`
- Ads via `google_mobile_ads`
- Dependencies prepared for Hive persistence integration
