import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final budgets = await DatabaseService.getBudgets();
    final loans = await DatabaseService.getLoans();
    final credits = await DatabaseService.getCredits();
    if (!mounted) return;

    final now = DateTime.now();
    final items = <_NotificationItem>[];

    // Upcoming bills within 7 days
    for (final budget in budgets) {
      final daysLeft = budget.dueDate.difference(now).inDays;
      if (daysLeft >= 0 && daysLeft <= 7) {
        items.add(
          _NotificationItem(
            icon: Icons.receipt_long_rounded,
            color: daysLeft <= 2 ? AppColors.error : AppColors.warning,
            title:
                '${budget.name} due ${daysLeft == 0 ? 'today' : 'in $daysLeft day${daysLeft == 1 ? '' : 's'}'}',
            subtitle: budget.amount > 0
                ? '₱${NumberFormat('#,##0').format(budget.amount)}'
                : 'Free',
            time: budget.dueDate,
            type: _NotificationType.bill,
          ),
        );
      }
    }

    // Upcoming loan payments within 7 days
    for (final loan in loans) {
      final upcoming =
          loan.transactions.where((t) => t.status == 'Upcoming').toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      if (upcoming.isNotEmpty) {
        final next = upcoming.first;
        final daysLeft = next.dueDate.difference(now).inDays;
        if (daysLeft >= 0 && daysLeft <= 7) {
          items.add(
            _NotificationItem(
              icon: Icons.account_balance_rounded,
              color: daysLeft <= 2 ? AppColors.error : AppColors.secondary,
              title:
                  '${loan.name} payment ${daysLeft == 0 ? 'today' : 'in $daysLeft day${daysLeft == 1 ? '' : 's'}'}',
              subtitle: '₱${NumberFormat('#,##0').format(next.amountDue)}',
              time: next.dueDate,
              type: _NotificationType.loan,
            ),
          );
        }
      }
    }

    // Credit card payments due within 7 days
    for (final credit in credits) {
      if (credit.status == 'Pending') {
        final daysLeft = credit.dueDate.difference(now).inDays;
        if (daysLeft >= 0 && daysLeft <= 7) {
          items.add(
            _NotificationItem(
              icon: Icons.credit_card_rounded,
              color: daysLeft <= 2 ? AppColors.error : AppColors.accent,
              title:
                  '${credit.name} payment ${daysLeft == 0 ? 'today' : 'in $daysLeft day${daysLeft == 1 ? '' : 's'}'}',
              subtitle:
                  '₱${NumberFormat('#,##0').format(credit.outstandingBalance)}',
              time: credit.dueDate,
              type: _NotificationType.credit,
            ),
          );
        }
      }
    }

    // Sort by urgency (soonest first)
    items.sort((a, b) => a.time.compareTo(b.time));

    setState(() {
      _notifications = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No upcoming payments in the next 7 days',
            style: TextStyle(fontSize: 14, color: context.subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return _buildNotificationCard(item);
      },
    );
  }

  Widget _buildNotificationCard(_NotificationItem item) {
    final now = DateTime.now();
    final daysLeft = item.time.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: daysLeft <= 1
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
        boxShadow: [AppDecorations.cardShadow(context)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: daysLeft <= 1
                  ? AppColors.error.withValues(alpha: 0.1)
                  : context.chipBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('MMM d').format(item.time),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: daysLeft <= 1 ? AppColors.error : context.subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationType { bill, loan, credit }

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime time;
  final _NotificationType type;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}
