import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';

class DatabaseService {
  static Database? _db;
  static const int _version = 1;

  static Future<void> initialize() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'expensar.db'),
      version: _version,
      onCreate: _onCreate,
    );
  }

  static Database get db {
    assert(_db != null, 'DatabaseService.initialize() must be called first');
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        status TEXT,
        expectedPayoutDate TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        payDays TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE wallet_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        walletId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        serviceCharge REAL,
        postBalance REAL NOT NULL,
        FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE credits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        creditLimit REAL NOT NULL,
        availableCredit REAL NOT NULL,
        outstandingBalance REAL NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE credit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        creditId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        outstandingBalance REAL NOT NULL,
        postAvailableCredit REAL NOT NULL,
        FOREIGN KEY (creditId) REFERENCES credits(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        remainingBalance REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE debt_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debtId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        amountPaid REAL,
        amountBorrowed REAL,
        paymentFrom TEXT,
        remainingBalance REAL,
        FOREIGN KEY (debtId) REFERENCES debts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        paidAmount REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        principalAmount REAL NOT NULL,
        netProceeds REAL NOT NULL,
        interestRate REAL NOT NULL,
        loanTerm TEXT NOT NULL,
        processingFee REAL,
        adminFee REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE loan_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loanId INTEGER NOT NULL,
        month TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        amountDue REAL NOT NULL,
        status TEXT NOT NULL,
        paidDate TEXT,
        paidAmount REAL,
        description TEXT,
        FOREIGN KEY (loanId) REFERENCES loans(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // --- Settings ---

  static Future<String?> getSetting(String key) async {
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  static Future<void> setSetting(String key, String value) async {
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Wallets ---

  static Future<List<Wallet>> getWallets() async {
    final maps = await db.query('wallets');
    final wallets = <Wallet>[];
    for (final map in maps) {
      final logs = await db.query(
        'wallet_logs',
        where: 'walletId = ?',
        whereArgs: [map['id']],
        orderBy: 'date DESC',
      );
      wallets.add(
        Wallet.fromMap(map, logs: logs.map(WalletLog.fromMap).toList()),
      );
    }
    return wallets;
  }

  static Future<int> insertWallet(Wallet wallet) async {
    return await db.insert('wallets', wallet.toMap());
  }

  static Future<void> updateWallet(Wallet wallet) async {
    await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  static Future<void> deleteWallet(int id) async {
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertWalletLog(WalletLog log) async {
    return await db.insert('wallet_logs', log.toMap());
  }

  // --- Budgets ---

  static Future<List<Budget>> getBudgets() async {
    final maps = await db.query('budgets');
    return maps.map(Budget.fromMap).toList();
  }

  static Future<int> insertBudget(Budget budget) async {
    return await db.insert('budgets', budget.toMap());
  }

  static Future<void> updateBudget(Budget budget) async {
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  static Future<void> deleteBudget(int id) async {
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // --- Credits ---

  static Future<List<Credit>> getCredits() async {
    final maps = await db.query('credits');
    final credits = <Credit>[];
    for (final map in maps) {
      final logs = await db.query(
        'credit_logs',
        where: 'creditId = ?',
        whereArgs: [map['id']],
        orderBy: 'date DESC',
      );
      credits.add(
        Credit.fromMap(map, logs: logs.map(CreditLog.fromMap).toList()),
      );
    }
    return credits;
  }

  static Future<int> insertCredit(Credit credit) async {
    return await db.insert('credits', credit.toMap());
  }

  static Future<void> updateCredit(Credit credit) async {
    await db.update(
      'credits',
      credit.toMap(),
      where: 'id = ?',
      whereArgs: [credit.id],
    );
  }

  static Future<void> deleteCredit(int id) async {
    await db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertCreditLog(CreditLog log) async {
    return await db.insert('credit_logs', log.toMap());
  }

  // --- Debts ---

  static Future<List<Debt>> getDebts() async {
    final maps = await db.query('debts');
    final debts = <Debt>[];
    for (final map in maps) {
      final logs = await db.query(
        'debt_logs',
        where: 'debtId = ?',
        whereArgs: [map['id']],
        orderBy: 'date DESC',
      );
      debts.add(Debt.fromMap(map, logs: logs.map(DebtLog.fromMap).toList()));
    }
    return debts;
  }

  static Future<int> insertDebt(Debt debt) async {
    return await db.insert('debts', debt.toMap());
  }

  static Future<void> updateDebt(Debt debt) async {
    await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  static Future<void> deleteDebt(int id) async {
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertDebtLog(DebtLog log) async {
    return await db.insert('debt_logs', log.toMap());
  }

  // --- Loans ---

  static Future<List<Loan>> getLoans() async {
    final maps = await db.query('loans');
    final loans = <Loan>[];
    for (final map in maps) {
      final txMaps = await db.query(
        'loan_transactions',
        where: 'loanId = ?',
        whereArgs: [map['id']],
        orderBy: 'dueDate ASC',
      );
      loans.add(
        Loan.fromMap(
          map,
          transactions: txMaps.map(LoanTransaction.fromMap).toList(),
        ),
      );
    }
    return loans;
  }

  static Future<int> insertLoan(Loan loan) async {
    return await db.insert('loans', loan.toMap());
  }

  static Future<void> updateLoan(Loan loan) async {
    await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  static Future<void> deleteLoan(int id) async {
    await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertLoanTransaction(LoanTransaction tx) async {
    return await db.insert('loan_transactions', tx.toMap());
  }

  static Future<void> updateLoanTransaction(LoanTransaction tx) async {
    await db.update(
      'loan_transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  // --- Clear all ---

  static Future<void> clearAllData() async {
    await db.delete('wallet_logs');
    await db.delete('wallets');
    await db.delete('budgets');
    await db.delete('credit_logs');
    await db.delete('credits');
    await db.delete('debt_logs');
    await db.delete('debts');
    await db.delete('loan_transactions');
    await db.delete('loans');
    await db.delete('settings');
  }
}
