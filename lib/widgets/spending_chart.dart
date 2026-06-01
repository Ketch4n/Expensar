import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class SpendingChart extends StatelessWidget {
  final List<double> data;
  final double todayAmount;
  final double weekTotal;
  final double monthTotal;

  const SpendingChart({
    super.key,
    required this.data,
    required this.todayAmount,
    this.weekTotal = 0,
    this.monthTotal = 0,
  });

  List<String> _getDayLabels() {
    final now = DateTime.now();
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List.generate(data.length, (i) {
      final day = now.subtract(Duration(days: data.length - 1 - i));
      return dayLetters[day.weekday - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = _getDayLabels();
    final hasData = data.any((d) => d > 0);
    final maxY = hasData ? data.reduce((a, b) => a > b ? a : b) * 1.2 : 100.0;

    // Calculate comparison with yesterday
    final yesterday = data.length >= 2 ? data[data.length - 2] : 0.0;
    final isUp = todayAmount > yesterday;
    final diff = todayAmount - yesterday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPENDING · LAST ${data.length} DAYS',
                style: TextStyle(
                  fontSize: 11,
                  color: context.subtitleColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                DateFormat('MMM d').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                height: 80,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < dayLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  dayLabels[idx],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: idx == dayLabels.length - 1
                                        ? AppColors.primary
                                        : context.subtitleColor,
                                    fontWeight: idx == dayLabels.length - 1
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      data.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[index] == 0 ? 0.5 : data[index],
                            color: index == data.length - 1
                                ? AppColors.primary
                                : context.isDark
                                ? Colors.grey[700]!
                                : const Color(0xFFE0E0E0),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          color: isUp ? Colors.red[400] : Colors.green[400],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '₱${NumberFormat('#,##0.00').format(todayAmount)}',
                            style: AppTextStyles.amountLarge.copyWith(
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (hasData && yesterday > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${isUp ? '+' : ''}₱${NumberFormat('#,##0').format(diff)} vs yesterday',
                        style: TextStyle(
                          fontSize: 10,
                          color: isUp ? Colors.red[300] : Colors.green[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatChip(
                          label: 'Week',
                          value: '₱${NumberFormat('#,##0').format(weekTotal)}',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Month',
                          value: '₱${NumberFormat('#,##0').format(monthTotal)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: context.subtitleColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
