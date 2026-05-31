# Expensar - Budget Tracker App

A beautiful and intuitive budget tracking application built with Flutter.

## Features

- 📊 **Dashboard Overview** - See your spending at a glance
- 💰 **Transaction Tracking** - Track income and expenses
- 📈 **Spending Charts** - Visualize your last 7 days of spending
- 📅 **Payday Countdown** - Know exactly when your next payday is
- 🎯 **Smart Insights** - Get personalized spending advice

## Screenshots

The app features a clean, modern design with:

- Personalized greeting with spending insights
- Interactive spending chart with day/week/month views
- Payday countdown card
- Upcoming transactions list (income & expenses)
- Bottom navigation for easy access

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository

```bash
git clone <your-repo-url>
cd expensar
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── transaction.dart      # Transaction data model
├── data/
│   └── sample_data.dart      # Sample data for demo
├── widgets/
│   ├── greeting_card.dart    # Personalized greeting widget
│   ├── spending_chart.dart   # Chart widget with fl_chart
│   ├── payday_card.dart      # Payday countdown widget
│   └── transaction_list.dart # Transaction list widget
└── screens/
    └── dashboard_screen.dart # Main dashboard screen
```

## Dependencies

- `google_fonts` - Beautiful typography
- `intl` - Date and number formatting
- `fl_chart` - Interactive charts

## Customization

You can customize the app by:

- Modifying colors in `lib/main.dart` theme
- Updating sample data in `lib/data/sample_data.dart`
- Adding new transaction types in `lib/models/transaction.dart`

## Future Enhancements

- [ ] Add transaction creation
- [ ] Implement data persistence (SQLite/Hive)
- [ ] Add budget goals and limits
- [ ] Category-based expense tracking
- [ ] Export reports
- [ ] Multi-currency support

## License

This project is open source and available under the MIT License.
