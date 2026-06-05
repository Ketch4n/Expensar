import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../models/account_group.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import '../services/database_service.dart';

/// Wallets provider — fetches from DB and can be refreshed.
class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getWallets();
  }
}

final walletsProvider = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
  (ref) => WalletsNotifier(),
);

/// Account Groups provider.
class AccountGroupsNotifier extends StateNotifier<List<AccountGroup>> {
  AccountGroupsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getAccountGroups();
  }
}

final accountGroupsProvider =
    StateNotifierProvider<AccountGroupsNotifier, List<AccountGroup>>(
      (ref) => AccountGroupsNotifier(),
    );

/// Budgets provider.
class BudgetsNotifier extends StateNotifier<List<Budget>> {
  BudgetsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getBudgets();
  }
}

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<Budget>>(
  (ref) => BudgetsNotifier(),
);

/// Credits provider.
class CreditsNotifier extends StateNotifier<List<Credit>> {
  CreditsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getCredits();
  }
}

final creditsProvider = StateNotifierProvider<CreditsNotifier, List<Credit>>(
  (ref) => CreditsNotifier(),
);

/// Debts provider.
class DebtsNotifier extends StateNotifier<List<Debt>> {
  DebtsNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getDebts();
  }
}

final debtsProvider = StateNotifierProvider<DebtsNotifier, List<Debt>>(
  (ref) => DebtsNotifier(),
);

/// Loans provider.
class LoansNotifier extends StateNotifier<List<Loan>> {
  LoansNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    state = await DatabaseService.getLoans();
  }
}

final loansProvider = StateNotifierProvider<LoansNotifier, List<Loan>>(
  (ref) => LoansNotifier(),
);
