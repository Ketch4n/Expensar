import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

/// Handles exporting and importing all app data as JSON.
class BackupService {
  const BackupService._();

  /// Export all data to a JSON file. Returns the file path.
  static Future<String> exportData() async {
    final wallets = await DatabaseService.getWallets();
    final budgets = await DatabaseService.getBudgets();
    final credits = await DatabaseService.getCredits();
    final debts = await DatabaseService.getDebts();
    final loans = await DatabaseService.getLoans();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'wallets': wallets
          .map(
            (w) => {
              ...w.toMap(),
              'logs': w.logs.map((l) => l.toMap()).toList(),
            },
          )
          .toList(),
      'budgets': budgets.map((b) => b.toMap()).toList(),
      'credits': credits
          .map(
            (c) => {
              ...c.toMap(),
              'logs': c.logs.map((l) => l.toMap()).toList(),
            },
          )
          .toList(),
      'debts': debts
          .map(
            (d) => {
              ...d.toMap(),
              'logs': d.logs.map((l) => l.toMap()).toList(),
            },
          )
          .toList(),
      'loans': loans
          .map(
            (l) => {
              ...l.toMap(),
              'transactions': l.transactions.map((t) => t.toMap()).toList(),
            },
          )
          .toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/expensar_backup_$timestamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  /// Import data from a JSON file. Clears existing data first.
  static Future<ImportResult> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, message: 'File not found');
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Validate structure
      if (!data.containsKey('wallets') || !data.containsKey('budgets')) {
        return ImportResult(
          success: false,
          message: 'Invalid backup file format',
        );
      }

      // Clear existing data
      await DatabaseService.clearAllData();

      // Import wallets and their logs
      final walletsList = data['wallets'] as List? ?? [];
      for (final walletMap in walletsList) {
        final map = Map<String, dynamic>.from(walletMap);
        final logs = map.remove('logs') as List? ?? [];
        // Remove the old id so SQLite assigns a new one
        map.remove('id');
        final walletId = await DatabaseService.db.insert('wallets', map);

        for (final logMap in logs) {
          final logData = Map<String, dynamic>.from(logMap);
          logData.remove('id');
          logData['walletId'] = walletId;
          await DatabaseService.db.insert('wallet_logs', logData);
        }
      }

      // Import budgets
      final budgetsList = data['budgets'] as List? ?? [];
      for (final budgetMap in budgetsList) {
        final map = Map<String, dynamic>.from(budgetMap);
        map.remove('id');
        await DatabaseService.db.insert('budgets', map);
      }

      // Import credits and their logs
      final creditsList = data['credits'] as List? ?? [];
      for (final creditMap in creditsList) {
        final map = Map<String, dynamic>.from(creditMap);
        final logs = map.remove('logs') as List? ?? [];
        map.remove('id');
        final creditId = await DatabaseService.db.insert('credits', map);

        for (final logMap in logs) {
          final logData = Map<String, dynamic>.from(logMap);
          logData.remove('id');
          logData['creditId'] = creditId;
          await DatabaseService.db.insert('credit_logs', logData);
        }
      }

      // Import debts and their logs
      final debtsList = data['debts'] as List? ?? [];
      for (final debtMap in debtsList) {
        final map = Map<String, dynamic>.from(debtMap);
        final logs = map.remove('logs') as List? ?? [];
        map.remove('id');
        final debtId = await DatabaseService.db.insert('debts', map);

        for (final logMap in logs) {
          final logData = Map<String, dynamic>.from(logMap);
          logData.remove('id');
          logData['debtId'] = debtId;
          await DatabaseService.db.insert('debt_logs', logData);
        }
      }

      // Import loans and their transactions
      final loansList = data['loans'] as List? ?? [];
      for (final loanMap in loansList) {
        final map = Map<String, dynamic>.from(loanMap);
        final transactions = map.remove('transactions') as List? ?? [];
        map.remove('id');
        final loanId = await DatabaseService.db.insert('loans', map);

        for (final txMap in transactions) {
          final txData = Map<String, dynamic>.from(txMap);
          txData.remove('id');
          txData['loanId'] = loanId;
          await DatabaseService.db.insert('loan_transactions', txData);
        }
      }

      final totalItems =
          walletsList.length +
          budgetsList.length +
          creditsList.length +
          debtsList.length +
          loansList.length;

      return ImportResult(
        success: true,
        message: 'Imported $totalItems items successfully',
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }
}

class ImportResult {
  final bool success;
  final String message;

  const ImportResult({required this.success, required this.message});
}
