import '../models/wallet.dart';
import '../models/budget.dart';
import '../models/credit.dart';
import '../models/debt.dart';
import '../models/loan.dart';
import 'database_service.dart';

/// Seeds the database with initial data from the JSON budget files.
/// Call [seedAll] once to populate the database.
class DataSeeder {
  const DataSeeder._();

  static Future<void> seedAll() async {
    await _seedWallets();
    await _seedBudgets();
    await _seedCredits();
    await _seedDebts();
    await _seedLoans();
  }

  static Future<void> _seedWallets() async {
    // Security Bank
    final secBankId = await DatabaseService.insertWallet(
      Wallet(
        name: 'Security Bank',
        balance: 0.00,
        type: 'Debit',
        expectedPayoutDate: DateTime.parse('2026-06-15'),
        isRecurring: true,
        payDays: [15, 30],
        currency: 'PHP',
      ),
    );
    await DatabaseService.insertWalletLog(
      WalletLog(
        walletId: secBankId,
        date: DateTime.parse('2026-05-30 09:35:00'),
        description: 'Transfer to GoTyme',
        amount: 41977.98,
        serviceCharge: 10.00,
        postBalance: 0.00,
      ),
    );
    await DatabaseService.insertWalletLog(
      WalletLog(
        walletId: secBankId,
        date: DateTime.parse('2026-05-30 09:22:00'),
        description: 'First Salary for the month of May',
        amount: 41987.98,
        postBalance: 41987.98,
      ),
    );

    // GoTyme
    final goTymeId = await DatabaseService.insertWallet(
      Wallet(name: 'GoTyme', balance: 21411.74, type: 'Debit', currency: 'PHP'),
    );
    final goTymeLogs = [
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Mang Inasal Lunch',
        amount: 470.00,
        postBalance: 21411.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Send to Mom',
        amount: 3000.00,
        postBalance: 21881.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Jollibee Lunch',
        amount: 367.00,
        postBalance: 24881.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 14:30:00'),
        description: 'Withdraw to Cash',
        amount: 8000.00,
        serviceCharge: 18.00,
        postBalance: 25248.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 13:36:00'),
        description: 'Send to Labhuyn',
        amount: 3018.00,
        postBalance: 33266.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 10:30:00'),
        description: 'Send payment to Ayra',
        amount: 5000.00,
        postBalance: 36284.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 10:00:00'),
        description: 'Send to Kenot',
        amount: 1000.00,
        postBalance: 41284.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 09:35:00'),
        description: 'Transfer from Secured Bank',
        amount: 41977.98,
        postBalance: 42284.74,
      ),
      WalletLog(
        walletId: goTymeId,
        date: DateTime.parse('2026-05-30 06:00:00'),
        description: 'Previous Balance',
        amount: 306.76,
        postBalance: 306.76,
      ),
    ];
    for (final log in goTymeLogs) {
      await DatabaseService.insertWalletLog(log);
    }

    // Alliance last payout
    await DatabaseService.insertWallet(
      Wallet(
        name: 'Alliance last payout',
        balance: 19550.89,
        type: 'Debit',
        status: 'Upcoming',
        expectedPayoutDate: DateTime.parse('2026-06-09'),
        currency: 'PHP',
      ),
    );

    // Cash
    final cashId = await DatabaseService.insertWallet(
      Wallet(name: 'Cash', balance: 5070.00, type: 'Debit', currency: 'PHP'),
    );
    final cashLogs = [
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-06-01 14:37:00'),
        description: 'Dinner',
        amount: 301.00,
        postBalance: 5070.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-06-01 14:37:00'),
        description: 'Fare from and to work',
        amount: 79.00,
        postBalance: 5371.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'SC items',
        amount: 80.00,
        postBalance: 5450.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'SC to Ayala',
        amount: 50.00,
        postBalance: 5319.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Rice 2 kilos',
        amount: 112.00,
        postBalance: 5319.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Mouse Trap',
        amount: 35.00,
        postBalance: 5431.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Alcohol',
        amount: 98.00,
        postBalance: 5466.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Water 7 liters',
        amount: 20.00,
        postBalance: 5564.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Ice and 3 Eggs',
        amount: 40.00,
        postBalance: 5584.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Islander Slipper',
        amount: 500.00,
        postBalance: 5634.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: 'Kalamansi Juice',
        amount: 100.00,
        postBalance: 6134.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-31 14:37:00'),
        description: "Labhuyn's allowance",
        amount: 200.00,
        postBalance: 6234.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Dinner expenses',
        amount: 180.00,
        postBalance: 6434.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: "Labhuyn's allowance",
        amount: 200.00,
        postBalance: 6614.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: "Labhuyn's haircut",
        amount: 150.00,
        postBalance: 6814.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Haircut',
        amount: 150.00,
        postBalance: 6964.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Cellphone repair',
        amount: 1800.00,
        postBalance: 7114.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:37:00'),
        description: 'Wired Headset',
        amount: 200.00,
        postBalance: 8914.00,
      ),
      WalletLog(
        walletId: cashId,
        date: DateTime.parse('2026-05-30 14:30:00'),
        description: 'Withdraw from GoTyme',
        amount: 8000.00,
        postBalance: 8914.00,
      ),
    ];
    for (final log in cashLogs) {
      await DatabaseService.insertWalletLog(log);
    }
  }

  static Future<void> _seedBudgets() async {
    await DatabaseService.insertBudget(
      Budget(
        name: 'DITO WiFi',
        amount: 790.00,
        dueDate: DateTime.parse('2026-06-04'),
        status: 'Upcoming',
        category: 'budget',
      ),
    );
    await DatabaseService.insertBudget(
      Budget(
        name: 'Electricity Bill',
        amount: 1000.00,
        dueDate: DateTime.parse('2026-06-14'),
        status: 'Upcoming',
        category: 'budget',
      ),
    );
    await DatabaseService.insertBudget(
      Budget(
        name: 'Canva Pro',
        amount: 0.00,
        dueDate: DateTime.parse('2026-06-29'),
        status: 'Upcoming',
        category: 'subscription',
        description: 'Free trial for 30 days, then monthly subscription',
      ),
    );
  }

  static Future<void> _seedCredits() async {
    // Maya Easy Credit
    final mayaEasyId = await DatabaseService.insertCredit(
      Credit(
        name: 'Maya Easy Credit',
        creditLimit: 3000.00,
        availableCredit: 0.00,
        outstandingBalance: 3241.55,
        dueDate: DateTime.parse('2026-06-11'),
        status: 'Pending',
      ),
    );
    await DatabaseService.insertCreditLog(
      CreditLog(
        creditId: mayaEasyId,
        date: DateTime.parse('2026-05-15'),
        description: 'Borrowed for cash in Manila',
        amount: 3000.00,
        outstandingBalance: 3241.55,
        postAvailableCredit: 0.00,
      ),
    );

    // Maya Black
    final mayaBlackId = await DatabaseService.insertCredit(
      Credit(
        name: 'Maya Black',
        creditLimit: 57000.00,
        availableCredit: 37820.68,
        outstandingBalance: 19179.32,
        dueDate: DateTime.parse('2026-06-16'),
        status: 'Pending',
      ),
    );
    await DatabaseService.insertCreditLog(
      CreditLog(
        creditId: mayaBlackId,
        date: DateTime.parse('2026-05-29'),
        description:
            'Accumulated expenses for the month of May including past month',
        amount: 19179.32,
        outstandingBalance: 19179.32,
        postAvailableCredit: 37820.68,
      ),
    );
  }

  static Future<void> _seedDebts() async {
    // Ayra - Paid
    final ayraId = await DatabaseService.insertDebt(
      Debt(
        name: 'Ayra',
        totalAmount: 8000,
        remainingBalance: 0,
        status: 'Paid',
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: ayraId,
        date: DateTime.parse('2026-05-30 10:30:00'),
        amountPaid: 5000,
        paymentFrom: 'GoTyme',
        remainingBalance: 0,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: ayraId,
        date: DateTime.parse('2026-05-29'),
        amountPaid: 3000,
        paymentFrom: 'TikTok loan',
        remainingBalance: 5000,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: ayraId,
        date: DateTime.parse('2026-05-15'),
        description: 'Borrowed for cash in Manila',
        amountBorrowed: 8000,
      ),
    );

    // Kenot - Paid
    final kenotId = await DatabaseService.insertDebt(
      Debt(
        name: 'Kenot',
        totalAmount: 1000,
        remainingBalance: 0,
        status: 'Paid',
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: kenotId,
        date: DateTime.parse('2026-05-30 10:00:00'),
        amountPaid: 1000,
        paymentFrom: 'GoTyme',
        remainingBalance: 0,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: kenotId,
        date: DateTime.parse('2026-05-15'),
        description: 'Borrowed for cash in Manila',
        amountBorrowed: 1000,
      ),
    );

    // Labhuyn - Pending
    final labhuynId = await DatabaseService.insertDebt(
      Debt(
        name: 'Labhuyn',
        totalAmount: 33500,
        remainingBalance: 22482,
        status: 'Pending',
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2026-05-30'),
        description: 'Agreement 50% discount on rent',
        amountPaid: 8000,
        remainingBalance: 22482,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2026-05-30 13:36:00'),
        amountPaid: 3018,
        paymentFrom: 'GoTyme',
        remainingBalance: 30482,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2026-04-30'),
        description: 'Accumulated monthly rent in Cebu',
        amountBorrowed: 16000,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2026-02-15'),
        description: 'Grocery credit payment in Cebu',
        amountBorrowed: 5000,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2026-01-21'),
        description: 'Pocket money for Mindanao',
        amountBorrowed: 5000,
      ),
    );
    await DatabaseService.insertDebtLog(
      DebtLog(
        debtId: labhuynId,
        date: DateTime.parse('2025-12-29'),
        description: 'Additional funds for my Laptop',
        amountBorrowed: 7500,
      ),
    );
  }

  static Future<void> _seedLoans() async {
    // Maya Personal Loan
    final mayaLoanId = await DatabaseService.insertLoan(
      Loan(
        name: 'Maya Personal Loan',
        balance: 15564.00,
        paidAmount: 4965.91,
        type: 'Personal Loan',
        principalAmount: 15000.00,
        netProceeds: 14944.52,
        interestRate: 2.10,
        loanTerm: '6 months',
      ),
    );
    final mayaLoanTxs = [
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'September',
        dueDate: DateTime.parse('2026-09-20'),
        amountDue: 2532.13,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'August',
        dueDate: DateTime.parse('2026-08-20'),
        amountDue: 2532.13,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'July',
        dueDate: DateTime.parse('2026-07-20'),
        amountDue: 2532.13,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'June',
        dueDate: DateTime.parse('2026-06-20'),
        amountDue: 2532.13,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'May',
        dueDate: DateTime.parse('2026-05-20'),
        amountDue: 2517.78,
        status: 'Paid',
        paidDate: DateTime.parse('2026-05-01 20:46:00'),
        paidAmount: 2517.78,
        description: 'Loan payment',
      ),
      LoanTransaction(
        loanId: mayaLoanId,
        month: 'April',
        dueDate: DateTime.parse('2026-04-20'),
        amountDue: 2448.13,
        status: 'Paid',
        paidDate: DateTime.parse('2026-03-28 20:24:00'),
        paidAmount: 2448.13,
        description: 'Loan payment',
      ),
    ];
    for (final tx in mayaLoanTxs) {
      await DatabaseService.insertLoanTransaction(tx);
    }

    // Tiktok Loan
    final tiktokLoanId = await DatabaseService.insertLoan(
      Loan(
        name: 'Tiktok Loan',
        balance: 6660.00,
        paidAmount: 0,
        type: 'Personal Loan',
        principalAmount: 6000.00,
        netProceeds: 5820.00,
        interestRate: 3.00,
        loanTerm: '2 months',
        adminFee: 180.00,
      ),
    );
    final tiktokTxs = [
      LoanTransaction(
        loanId: tiktokLoanId,
        month: 'July',
        dueDate: DateTime.parse('2026-07-29'),
        amountDue: 3330.00,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: tiktokLoanId,
        month: 'June',
        dueDate: DateTime.parse('2026-06-29'),
        amountDue: 3330.00,
        status: 'Upcoming',
      ),
    ];
    for (final tx in tiktokTxs) {
      await DatabaseService.insertLoanTransaction(tx);
    }

    // Gcash Gloan
    final gcashLoanId = await DatabaseService.insertLoan(
      Loan(
        name: 'Gcash Gloan',
        balance: 15564.00,
        paidAmount: 4965.91,
        type: 'Personal Loan',
        principalAmount: 20000.00,
        netProceeds: 19400.00,
        interestRate: 3.09,
        loanTerm: '12 months',
        processingFee: 600.00,
      ),
    );
    final gcashTxs = [
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'April',
        dueDate: DateTime.parse('2027-04-20'),
        amountDue: 2284.61,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'March',
        dueDate: DateTime.parse('2027-03-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'February',
        dueDate: DateTime.parse('2027-02-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'January',
        dueDate: DateTime.parse('2027-01-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'December',
        dueDate: DateTime.parse('2026-12-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'November',
        dueDate: DateTime.parse('2026-11-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'October',
        dueDate: DateTime.parse('2026-10-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'August',
        dueDate: DateTime.parse('2026-08-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'July',
        dueDate: DateTime.parse('2026-07-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'June',
        dueDate: DateTime.parse('2026-06-20'),
        amountDue: 2284.67,
        status: 'Upcoming',
      ),
      LoanTransaction(
        loanId: gcashLoanId,
        month: 'May',
        dueDate: DateTime.parse('2026-05-20'),
        amountDue: 2284.67,
        status: 'Paid',
        paidDate: DateTime.parse('2026-05-11 22:08:45'),
        paidAmount: 2284.67,
        description: 'Loan payment',
      ),
    ];
    for (final tx in gcashTxs) {
      await DatabaseService.insertLoanTransaction(tx);
    }
  }
}
