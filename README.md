# Spendly

Spendly is a Flutter expense tracker prototype built from the PRD: **Track money simply**.

## Implemented product features

- **Onboarding**: 3-page onboarding flow with app branding, supporting indicators, and Get Started transition.
- **Dashboard**:
  - Current spending total
  - Time filter (`This Month`, `Last 3 Months`)
  - Monthly budget progress indicator
  - Spending trends line chart
  - Recent transactions list
  - Banner ad slot
- **Add Expense**:
  - Amount
  - Category
  - Date
  - Note
  - Expense/Income type selector
- **Analytics**:
  - Category distribution pie chart + legend with percentages
  - Total monthly spending
  - Average daily spending
  - Top spending category
  - Banner ad slot
  - Interstitial trigger when entering analytics
- **Calendar View**:
  - Monthly date picker
  - Tap date to view transactions for that day
  - Daily total + transaction count
- **Settings**:
  - Currency selection
  - Monthly budget adjustment
  - Dark mode toggle
  - Export data action (CSV preview in snackbar)
  - About section

## Monetization behavior implemented

- AdMob SDK initialization.
- Banner placements on Dashboard and Analytics pages.
- Interstitial ad trigger:
  - after opening Analytics
  - after every 3 successfully added expenses

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
